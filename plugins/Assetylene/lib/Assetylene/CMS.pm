package Assetylene::CMS;

use strict;
use warnings;

use MT::Util qw{ encode_html };

# template_source.multi_asset_options callback, for MT6.2+.
# Insert the caption checkbox and textarea field.
sub xfrm_src_multi_asset_options {
    my ($cb, $app, $tmpl) = @_;

    # Is there an Asset Insertion template ready to use? If not, there's no
    # reason to supply the caption field or otherwise update the Asset Options
    # screen.
    my $blog = $app->blog;
    return unless $app->model('template')->exist({
        name    => 'Asset Insertion',
        type    => 'custom',
        blog_id => [ $blog->id, 0 ],
    });

    # Add the caption fields.
    my $html = <<HTML;
    <input type="checkbox"
        id="insert_caption-<mt:Var name="id">"
        name="insert_caption-<mt:Var name="id">"
        value="1" />
    <label for="insert_caption-<mt:Var name="id">">Insert a caption?</label>
    <div class="textarea-wrapper" style="margin-top: 3px;">
        <textarea name="caption-<mt:Var name="id">"
            style="height: 42px;"
            onfocus="getByID('insert_caption-<mt:Var name="id">').checked=true; return false;"
            class="text full full-width"><mt:Var name="caption"></textarea>
    </div>
HTML

    $$tmpl =~ s/(<mt:var name="options">)/$1$html/;

    # Instead of using MT::CMS::Asset::insert_asset, use our own.
    my $old = q{<input type="hidden" name="__mode" value="insert_asset" />};
    my $new = q{<input type="hidden" name="__mode" value="assetylene_insert_asset" />};
    $$tmpl =~ s/$old/$new/;

    # When building the json object with each asset's data, we also need to
    # parse the textarea field for the caption.
    my $old = q{jQuery(this).find('input').};
    my $new = q{jQuery(this).find('input,textarea').};
    $$tmpl =~ s/$old/$new/;
}

# template_param.multi_asset_options callback, for MT 6.2+.
# Populate the textarea field.
sub xfrm_param_multi_asset_options {
    my ($cb, $app, $param, $tmpl) = @_;

    my $i = 0;
    while ( $param->{options_loop}[$i] ) {
        next unless $param->{options_loop}[$i];

        # Get the asset.
        my $asset_id = $param->{options_loop}[$i]->{id};
        my $asset = $app->model('asset')->load( $asset_id );

        # Encode any special characters as HTML entities, since this
        # description is being placed in an HTML textarea:
        my $caption = encode_html( $asset->description );

        # Insert the caption into the param field.
        $param->{options_loop}[$i]->{caption} = $caption;

        # Increment to get the next item in the options_loop array.
        $i++;
    }
}

# Above in xfrm_src_multi_asset_options, the default __mode `insert_asset` (on
# the multi asset options screen) is replaced by a call to
# `assetylene_insert_asset`, here. This way Assetylene can process multiple
# images to be used with the custom Asset Insertion template module. The thing
# we really want to modify is the `else` below, where JSON is parsed.
sub assetylene_insert_asset {
    my $app = shift;
    my ($param) = @_;

    $app->validate_magic() or return;

    if (   $app->param('edit_field')
        && $app->param('edit_field') =~ m/^customfield_.*$/ )
    {
        return $app->permission_denied()
            unless $app->permissions;
    }
    else {
        return $app->permission_denied()
            unless $app->can_do('insert_asset');
    }

    # Load the user-defined "Asset Insertion" template module. (Currently,
    # this template must be named in English. Look both at the blog and
    # system level for this template.) If no template can be found, give up and use the standard asset insertion method.
    my $blog = $app->blog;
    my $insert_tmpl = $app->model('template')->load({
        name    => 'Asset Insertion',
        type    => 'custom',
        blog_id => [ $blog->id, 0 ],
    });

    # No Asset Insertion template? Just use MT's insert capability.
    if ( ! $insert_tmpl ) {
        require MT::CMS::Asset;
        return MT::CMS::Asset::insert_asset( $app, $param );
    }

    my $text;
    my $assets;
    if ( $app->param('no_insert') ) {
        $text   = '';
        $assets = $param->{assets};
    }
    elsif ( $app->param('direct_asset_insert') ) {
        $assets = $param->{assets};
        foreach my $a (@$assets) {
            my %param;
            $param{wrap_text} = 1;
            $param{new_entry} = $app->param('new_entry') ? 1 : 0;

            $a->on_upload( \%param );
            $param{enclose}
                = $app->param('edit_field') =~ /^customfield/ ? 1 : 0;
            my $html = $a->as_html( \%param );
            return $app->error( $a->error ) unless defined $html;

            $text .= $html;
        }
    }
    else {
        # Parse JSON.
        my $prefs = $app->param('prefs_json');
        $prefs =~ s/^"|"$//g;
        $prefs =~ s/\\//g;
        $prefs = eval { MT::Util::from_json($prefs) };
        if ( !$prefs ) {
            return $app->errtrans('Invalid request.');
        }

        # Look at each asset to be inserted and save $processed_asset with the
        # various data needed for the Asset Insertion template.
        foreach my $item (@$prefs) {
            push @$assets, _parse_asset_to_insert($item);
        }

        # Set the Assets context to use in the Asset Insertion template.
        my $ctx = $insert_tmpl->context;
        $ctx->stash( 'assets', $assets );

        $insert_tmpl->param( $param );

        my $ctx = $insert_tmpl->context;
        $ctx->stash('blog', $blog);
        $ctx->stash('blog_id', $blog->id);
        $ctx->stash('local_blog_id', $blog->id);

        # Process the user-defined template:
        my $new_html = $insert_tmpl->output;

        $text = $new_html;
    }

    my $tmpl;
    $tmpl = $app->load_tmpl(
        'dialog/asset_insert.tmpl',
        {   upload_html => $text || '',
            edit_field => scalar $app->param('edit_field') || '',
        },
    );

    my $ctx = $tmpl->context;
    $ctx->stash( 'assets', $assets );
    return $tmpl;
}

# Parse the individual asset to be inserted.
# Return the asset object, and a "processed asset" object that contains
# relevant content to be used in the Asset Insertion Template Module.
sub _parse_asset_to_insert {
    my ($item) = @_;
    my ($app)  = MT->instance;

    my $id = $item->{id};
    return $app->errtrans('Asset ID not found.')
        unless $id;

    my $asset = MT::Asset->load($id)
        or return $app->errtrans( 'Cannot load asset #[_1]', $id );

    # Save the values from the asset Insert Options screen. These
    $asset->{column_values}->{wrap_text}   = 1;
    $asset->{column_values}->{new_entry}   = $app->param('new_entry') ? 1 : 0;
    $asset->{column_values}->{enclose}
        = $app->param('edit_field') =~ /^customfield/ ? 1 : 0;
    $asset->{column_values}->{include}     = $item->{include};

    $asset->{column_values}->{thumb}       = $item->{ 'thumb' };
    $asset->{column_values}->{thumb_width} = $item->{ 'thumb_width' };
    $asset->{column_values}->{align}       = $item->{ 'align-'.$id };
    $asset->{column_values}->{popup}       = $item->{ 'popup-'.$id };
    $asset->{column_values}->{caption}
        = $item->{ 'insert_caption-'.$id } ? $item->{ 'caption-'.$id } : '';

    # Prepare any thumbnail or popup assets that may be needed, and also
    # generate the standard default HTML, in case the user wants to use it.
    my %param;
    foreach my $k ( keys %$item ) {
        my $name = $k;
        if ( $k =~ m/(.*)[-|_]$id/ig ) {
            $name = $1;
        }
        $param{$name} = $item->{$k};
    }
    $param{wrap_text} = 1;
    $param{new_entry} = $app->param('new_entry') ? 1 : 0;
    $asset->on_upload( \%param );
    $asset->{column_values}->{default_html} = $asset->as_html( \%param );

    return $asset;
}

1;

__END__
