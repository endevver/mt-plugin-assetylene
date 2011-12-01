# This program is distributed under the terms of the
# GNU General Public License, version 2.
#

package Assetylene::CMS;

use strict;
use MT 4;
use Assetylene::L10N;
use MT::Util qw( encode_html );

sub asset_options_image {
    my ($cb, $app, $param, $tmpl) = @_;

    # Assertions:
    # 'asset_id' template parameter must be present.
    my $asset_id = $param->{asset_id} or return;

    # Asset object must be loadable
    my $asset = MT::Asset->load( $asset_id ) or return;

    # The 'image_alignment' MT template node must be in
    # the template we're working with to add our field above it.
    my $el = $tmpl->getElementById('image_alignment')
        or return;

    my $blog = $app->blog or return;
    my $plugin = MT->component("Assetylene");
    my $scope = "blog:".$blog->id;
    my $insert_tmpl = $app->model('template')->load({
                                                name => 'Asset Insertion',
                                                type => 'custom',
                                                blog_id => [ $blog->id, 0 ]
                                               }) ||
                      $app->model('template')->load({
                                                identifier => 'asset_insertion',
                                                type => 'custom',
                                                blog_id => [ $blog->id, 0 ]
                                               });

# Without Link >
    my $opt = $tmpl->createElement('app:setting', {
        id => 'without_link',
        label => MT->translate('Insert without Link'),
        label_class => 'no-header',
        hint => '',
        show_hint => 0,
    });
    $opt->innerHTML(<<HTML);
    <div>
        <input type="checkbox" id="without_link" name="without_link" value="1"
            onclick="if (this.checked) {
                         if (document.getElementById('insert_lightbox-field')) {
                             document.getElementById('insert_lightbox-field').style.display='none';
                         }
                         else {
                             document.getElementById('asset_lightbox-field').style.display='none';
                         }
                         document.getElementById('max_size-field').style.display='none';
                     }else{
                         if (document.getElementById('insert_lightbox-field')) {
                             document.getElementById('insert_lightbox-field').style.display='block';
                         }
                         else {
                             document.getElementById('asset_lightbox-field').style.display='block';
                         }
                         document.getElementById('max_size-field').style.display='block';
                     }" />
        <label for="without_link"><__trans_section component="Assetylene"><__trans phrase='Insert without Link'></__trans_section></label>
    </div>
HTML
    $tmpl->insertBefore($opt, $el);
#< Without Link
# Max Original Size >
    my $resize_link = $plugin->get_config_value('resize_link',$scope) || 0;
    my $resize_check = $resize_link ? 'hidden' : 'checkbox';
    my $readonly_w = $resize_link ? ' readonly="readonly"' : '';
    my $readonly_h = $resize_link ? ' readonly="readonly"' : '';
    my $show_input = $resize_link ? 'block' : 'none';
    my $max_link_width = $plugin->get_config_value('max_link_width',$scope);
    my $max_link_height = $plugin->get_config_value('max_link_height',$scope);

    $opt = $tmpl->createElement('app:setting', {
        id => 'max_size',
        label => MT->translate('Max Link Size'),
        label_class => 'no-header',
        hint => '',
        show_hint => 0,
    });
    $opt->innerHTML(<<HTML);
    <div>
        <input type="$resize_check" id="resize_link" name="resize_link" value="1"
            onclick="if (this.checked) {
                         document.getElementById('max_size').style.display='block';
                     }else{
                         document.getElementById('max_size').style.display='none';
                     }" />
        <label><__trans_section component="Assetylene"><__trans phrase='Resize Link'></__trans_section></label>
    </div>
    <div id="max_size">
        <label for="max_link_width"><__trans_section component="Assetylene"><__trans phrase='Max Link Size'></__trans_section></label>
        <input type="text" id="max_link_width" name="max_link_width" value="$max_link_width" style="width:8em;"$readonly_w /> x 
        <input type="text" id="max_link_height" name="max_link_height" value="$max_link_height" style="width:8em;"$readonly_h />
    </div>
    <script type="text/javascript">
        document.getElementById('max_size').style.display='$show_input';
    </script>
HTML
    $tmpl->insertBefore($opt, $el);
#< Max Original Size
# Caption >
    $opt = $tmpl->createElement('app:setting', {
        id => 'asset_optins',
        label => MT->translate('Asset Options'),
        label_class => 'no-header',
        hint => '',
        show_hint => 0,
    });
    require MT::Util;
    # Encode any special characters as HTML entities, since this
    # description is being placed in an HTML textarea:
    my $caption_safe = MT::Util::encode_html( $asset->description );

    if ($insert_tmpl) {
        $opt->innerHTML(<<HTML);
<div class="field">
    <input type="checkbox" id="insert_caption" name="insert_caption" value="1" />
    <label for="insert_caption"><__trans_section component="Assetylene"><__trans phrase='Insert a caption?'></__trans_section></label>
    <div class="textarea-wrapper"><textarea name="caption" style="height: 36px;" rows="2" cols="60"
        onfocus="getByID('insert_caption').checked=true; return false;"
        class="full-width">$caption_safe</textarea></div>
</div>
HTML
    }
    else {
        $opt->innerHTML(<<HTML);
<div class="field">
    <input type="checkbox" id="insert_caption" name="insert_caption" value="1" />
    <label for="insert_caption"><__trans_section component="Assetylene"><__trans phrase='Set alt attribute in image?'></__trans_section></label>
    <input type="text" name="caption" onfocus="getByID('insert_caption').checked=true; return false;"
        value="$caption_safe" style="width:16em;" />
</div>
HTML
    }
    $tmpl->insertBefore($opt, $el);
#< Caption
# Pattern >
    if ($insert_tmpl) {
        $opt = $tmpl->createElement('app:setting', {
            id => 'asset_optins',
            label => MT->translate('Asset Options'),
            label_class => 'no-header',
            hint => '',
            show_hint => 0,
        });
        my $insert_options = '';
        my $pattern_name1 = MT::Util::encode_html($plugin->get_config_value('pattern1',$scope),1);
        if ($pattern_name1) {
            $insert_options .= '<option value="1">' . $pattern_name1 . '</option>' . "\n";
        }
        my $pattern_name2 = MT::Util::encode_html($plugin->get_config_value('pattern2',$scope),1);
        if ($pattern_name2) {
            $insert_options .= '<option value="2">' . $pattern_name2 . '</option>' . "\n";
        }
        my $pattern_name3 = MT::Util::encode_html($plugin->get_config_value('pattern3',$scope),1);
        if ($pattern_name3) {
            $insert_options .= '<option value="3">' . $pattern_name3 . '</option>' . "\n";
        }
        my $pattern_name4 = MT::Util::encode_html($plugin->get_config_value('pattern4',$scope),1);
        if ($pattern_name4) {
            $insert_options .= '<option value="4">' . $pattern_name4 . '</option>' . "\n";
        }
        my $pattern_name5 = MT::Util::encode_html($plugin->get_config_value('pattern5',$scope),1);
        if ($pattern_name5) {
            $insert_options .= '<option value="5">' . $pattern_name5 . '</option>' . "\n";
        }
        if ($insert_options) {
            $opt->innerHTML(<<HTML);
    <label for="pattern"><__trans_section component="Assetylene"><__trans phrase='Insertion Pattern'></__trans_section></label>
    <select name="pattern">
        $insert_options
    </select><br />
HTML
            $tmpl->insertBefore($opt, $el);
        }
    }
#< Pattern
# lightbox >
    $opt = $tmpl->createElement('app:setting', {
        id => 'asset_lightbox',
        label => MT->translate('Lightbox'),
        label_class => 'no-header',
        hint => '',
        show_hint => 0,
    });
    my $themeid = $blog->theme_id;
    if ($themeid ne 'mtVicunaSimple') {
        my $lb_select1 = $plugin->get_config_value('lb_select1',$scope);
        my $lb_select2 = $plugin->get_config_value('lb_select2',$scope);
        my $lb_select3 = $plugin->get_config_value('lb_select3',$scope);
        my $lb_select4 = $plugin->get_config_value('lb_select4',$scope);
        if (($lb_select1) ||($lb_select2) || ($lb_select3) || ($lb_select4)) {
            my $insert_options = '';
            my $lightbox_selector1 = MT::Util::encode_html($plugin->get_config_value('lightbox_selector1',$scope),1);
            if (($lb_select1) && ($lightbox_selector1)) {
                $insert_options .= '<option value="' . $lightbox_selector1 . '">' . $lightbox_selector1 . '</option>' . "\n";
            }
            my $lightbox_selector2 = MT::Util::encode_html($plugin->get_config_value('lightbox_selector2',$scope),1);
            if (($lb_select2) && ($lightbox_selector2)) {
                $insert_options .= '<option value="' . $lightbox_selector2 . '">' . $lightbox_selector2 . '</option>' . "\n";
            }
            my $lightbox_selector3 = MT::Util::encode_html($plugin->get_config_value('lightbox_selector3',$scope),1);
            if (($lb_select3) && ($lightbox_selector3)) {
                $insert_options .= '<option value="' . $lightbox_selector3 . '">' . $lightbox_selector3 . '</option>' . "\n";
            }
            my $lightbox_selector4 = MT::Util::encode_html($plugin->get_config_value('lightbox_selector4',$scope),1);
            if (($lb_select4) && ($lightbox_selector4)) {
               $insert_options .= '<option value="' . $lightbox_selector4 . '">' . $lightbox_selector4 . '</option>' . "\n";
            }
            if ($insert_options eq '') {
                $insert_options .= '<option value="rel=&quot;lightbox&quot;">rel=&quot;lightbox&quot;</option>' . "\n";
            }
            $opt->innerHTML(<<HTML);
        <div>
            <input type="checkbox" id="insert_lightbox" name="insert_lightbox"
                onclick="if(this.checked){document.getElementById('create_thumbnail').checked=true;
                  document.getElementById('thumb_width').focus();
                }else{
                  document.getElementById('create_thumbnail').checked=false;
                }"
                value="1"<mt:if name="make_thumb"> checked="checked" </mt:if> />
            <label for="insert_lightbox"><__trans_section component="Assetylene"><__trans phrase='Use Lightbox Effect'></__trans_section></label>
            <select id="insert_class" name="insert_class">
                $insert_options
            </select>
        </div>
HTML
            $tmpl->insertBefore($opt, $el);
        }
    }
# < lightbox
# Remove Popup >
    my $remove_popup = $plugin->get_config_value('remove_popup',$scope) || 1;
    if ($remove_popup) {
        my $popup_element = $tmpl->getElementById('link_to_popup');
        my $class_attr = $popup_element->getAttribute('class') || '';
        $class_attr = $class_attr ? ( 'hidden ' . $class_attr ) : 'hidden';
        $popup_element->setAttribute('class', $class_attr);
    }
# < Remove Popup
    # Force the tokens of the template to be reprocessed now that
    # we've manipulated it:
    $tmpl->rescan();
}

sub asset_insert {
    my ($cb, $app, $param, $tmpl) = @_;

    my $blog_id = $app->param('blog_id');
    my $upload_html = $param->{ upload_html };

    my ($html_img_tag) = $upload_html =~ /(<img\b[^>]+?>)/s;
    my ($html_img_src) = $html_img_tag =~ /\bsrc="([^\"]+)"/s;
    my ($html_a_tag) = $upload_html =~ /(<a\b[^>]+?>)/s;
    my ($html_a_href) = $html_a_tag =~ /\bhref="(.+?)"/s;

    use MT::Blog;
    my $blog = MT::Blog->load($blog_id) or die;
    my $themeid = $blog->theme_id;
    my $plugin = MT->component("Assetylene");
    my $scope = "blog:".$blog_id;

    my $insert_tmpl = $app->model('template')->load({
                                                name => 'Asset Insertion',
                                                type => 'custom',
                                                blog_id => [ $blog_id, 0 ]
                                               }) ||
                      $app->model('template')->load({
                                                identifier => 'asset_insertion',
                                                type => 'custom',
                                                blog_id => [ $blog_id, 0 ]
                                               });

    if ($themeid ne 'mtVicunaSimple') {
        my $cleanup_insert = $plugin->get_config_value('cleanup_insert',$scope);
        if ($cleanup_insert) {
            my $rightalign_class = $plugin->get_config_value('rightalign_class',$scope);
            my $centeralign_class = $plugin->get_config_value('centeralign_class',$scope);
            my $leftalign_class = $plugin->get_config_value('leftalign_class',$scope);
            my $wrap;
            if ($cleanup_insert == '1' || $cleanup_insert == '') {
                if ($upload_html =~ / class=\"mt-image-left\"/) {
                    $wrap = '<p class="'.$leftalign_class.'">';
                    if ($cleanup_insert == '') {
                        $wrap = '<p class="img_L">';
                    }
                }
                if ($upload_html =~ / class=\"mt-image-right\"/) {
                    $wrap = '<p class="'.$rightalign_class.'">';
                    if ($cleanup_insert == '') {
                        $wrap = '<p class="img_R">';
                    }
                }
                if ($upload_html =~ / class=\"mt-image-center\"/) {
                    if ($centeralign_class) {
                        $wrap = '<p class="'.$centeralign_class.'">';
                    } else {
                        $wrap = '<p>';
                    }
                    if ($cleanup_insert == '') {
                        $wrap = '<p>';
                    }
                }
                $upload_html =~ s/ class=\"mt-image-(none|right|left|center)\"//g;
            }
            elsif ($cleanup_insert == '2') {
                $upload_html =~ s/ class=\"mt-image-none\"//i;
                $rightalign_class = ' class="'.$rightalign_class.'"';
                $upload_html =~ s/ class=\"mt-image-right\"/$rightalign_class/g;
                $leftalign_class = ' class="'.$leftalign_class.'"';
                $upload_html =~ s/ class=\"mt-image-left\"/$leftalign_class/g;
                if ($centeralign_class) {
                    $centeralign_class = ' class="'.$centeralign_class.'"';
                }
                $upload_html =~ s/ class=\"mt-image-center\"/$centeralign_class/g;
            }
            $upload_html =~ s/ style=\"\"//i;
            $upload_html =~ s/ style=\"float\: (right|left)\; margin\: 0 (0|20px) 20px (0|20px)\;\"//i;
            $upload_html =~ s/ style=\"text-align\: center\; display\: block\; margin\: 0 auto 20px\;\"//i;
            if ($wrap) {
                $upload_html = $wrap.$upload_html.'</p>';
            }
        }
        my $insert_class = $app->param('insert_class');
        if ( $app->param('insert_lightbox') ) {
            $insert_class = '<a '.$insert_class;
            $upload_html =~ s/<a/$insert_class/g;
        }
    }
    if ($app->param('insert_caption')) {
        if ($app->param('caption')) {
            my $alt_caption = ' alt="'.$app->param('caption').'"';
            $upload_html =~ s/ alt="[^"]+"/$alt_caption/g;
        }
    }
    if ($app->param('without_link')) {
        $upload_html =~ s/^.*(<img [^>]+>).*$/$1/;
    }
    my $original = $tmpl->context->stash('asset');
    my $resize_link = $plugin->get_config_value('resize_link',$scope) || $app->param('resize_link');
    if ($resize_link) {
        my $max_width = $app->param('max_link_width') || $plugin->get_config_value('max_link_width',$scope) || 0;
        my $max_height = $app->param('max_link_height') || $plugin->get_config_value('max_link_height',$scope) || 0;
        $max_width = ( $original->image_width > $max_width ) ? $max_width : 0;
        $max_height = ( $original->image_height > $max_height ) ? $max_height : 0;
        if ($max_width + $max_height) {
            my %param;
            $param{Width} = $max_width if $max_width;
            $param{Height} = $max_height if $max_height;
            my ( $thumbnail, $w, $h ) = $original->thumbnail_file( %param );
            require MT::Asset;
            (my $site_path = $blog->site_path) =~ s!\\!/!g;
            my $site_url  = $blog->site_url;
            my $regex_path = quotemeta( $site_path );
            $thumbnail =~ s!\\!/!g;
            (my $file_path  = $thumbnail)  =~ s/^$regex_path/%r/;
            $thumbnail =~ s/^$regex_path/$site_url/;
            $thumbnail =~ s!//!/!g;

            my $asset_pkg = MT::Asset->handler_for_file($thumbnail);
            my $asset = $asset_pkg->load({
                'file_path' => $file_path,
                'blog_id' => $blog->id,
            }) || $asset_pkg->new;
            unless ($asset->id) {
                $asset->url( $file_path );
                $asset->file_path( $file_path );
                require File::Basename;
                my $local_basename = File::Basename::basename($thumbnail);
                $asset->file_name( $local_basename );
                my $ext = ( File::Basename::fileparse( $thumbnail, qr/[A-Za-z0-9]+$/ ) )[2];
                $asset->file_ext( $ext );
                $asset->blog_id( $blog->id) ;
                $asset->created_by( $app->user->id );
                require LWP::MediaTypes;
                my $mimetype = LWP::MediaTypes::guess_media_type( $asset->file_path );
                $asset->mime_type($mimetype) if $mimetype;
                $asset->image_width( $w );
                $asset->image_height( $h );
                $asset->parent( $original->id );
                $asset->save
                  or die;
            }
            $upload_html =~ s/href=".*?"/href="$thumbnail"/i;
        }
    }

    if ($insert_tmpl) {

        # Collect all the elements of the MT generated asset markup
        # so they can be manipulated indepdendently by the user-defined
        # template:
        my $html = $upload_html;
        my ($img_tag) = $html =~ /(<img\b[^>]+?>)/s;
        my ($a_tag) = $html =~ /(<a\b[^>]+?>)/s;
        my ($form_tag) = $html =~ /(<form[^>]+?>)/s;

        $param->{enclose} = 1 if $form_tag;
        $param->{include} = 1 if $app->param('include');
        $param->{thumb} = 1 if $app->param('thumb');
        ($param->{align}) = $app->param('align') =~ m/(\w+)/;
        $param->{caption} = $app->param('insert_caption') ? $app->param('caption') : '';
        $param->{popup} = 1 if $app->param('popup');

        $param->{label} = $original->label;
        $param->{description} = $original->description;
        $param->{asset_id} = $original->id;

        $param->{a_tag} = $a_tag;
        ($param->{a_href}) = $a_tag =~ /\bhref="(.+?)"/s;
        ($param->{a_onclick}) = $a_tag =~ /\bonclick="(.+?)"/s;

        ($param->{a_style}) = $a_tag =~ /\bstyle="([^\"]+)"/s;
        ($param->{a_class}) = $a_tag =~ /\bclass="([^\"]+)"/s;
        ($param->{a_title}) = $a_tag =~ /\btitle="([^\"]+)"/s;
        ($param->{a_rel}) = $a_tag =~ /\brel="([^\"]+)"/s;

        $param->{form_tag} = $form_tag;
        ($param->{form_style}) = $form_tag =~ /\bstyle="([^\"]+)"/s;
        ($param->{form_class}) = $form_tag =~ /\bclass="([^\"]+)"/s;

        $param->{img_tag} = $img_tag;
        ($param->{img_height}) = $img_tag =~ /\bheight="(\d+)"/;
        ($param->{img_width}) = $img_tag =~ /\bwidth="(\d+)"/;
        ($param->{img_src}) = $img_tag =~ /\bsrc="([^\"]+)"/s;
        ($param->{img_style}) = $img_tag =~ /\bstyle="([^\"]+)"/s;
        ($param->{img_class}) = $img_tag =~ /\bclass="([^\"]+)"/s;
        ($param->{img_alt}) = $img_tag =~ /\balt="([^\"]+)"/s;

        $param->{pattern} = $app->param('pattern');

        $insert_tmpl->param( $param );

        my $ctx = $insert_tmpl->context;
        $ctx->stash('blog', $blog);
        $ctx->stash('blog_id', $blog->id);
        $ctx->stash('local_blog_id', $blog->id);
        $ctx->stash('asset', $original);

        # Process the user-defined template:
        my $new_html = $insert_tmpl->output;

        my $ua = $ENV{'HTTP_USER_AGENT'};
        if ($ua =~ /MSIE/) {
            $new_html =~ s/<!--[\s\S]*?-->//g;
        }
        else {
            # $new_html =~ s/<!--[\s\S]*?-->//g;
        }

        my $remove_blank = $plugin->get_config_value('remove_blank',$scope);
        if ($remove_blank) {
            $new_html =~ s/\s*\n+/\n/g;
        }

        if (defined($new_html)) {
            # Replace the MT generated asset markup with the user-defined
            # markup:
            $param->{upload_html} = $new_html;
        }
        else {
            # Template build error: die, so this gets logged (we're in a
            # callback, so it won't be surfaced to the user unfortunately)
            die "Error from Asset Insertion module: " . $insert_tmpl->errstr;
        }
    }
    else {
        $param->{upload_html} = $upload_html;
    }
}

sub template_source_assetylene {
    my ( $cb, $app, $tmpl ) = @_;
    my $src = 'none';
    my $blog_id = $app->param('blog_id');
    my $insert_tmpl = $app->model('template')->load({
                                                name => 'Asset Insertion',
                                                type => 'custom',
                                                blog_id => [ $blog_id, 0 ]
                                               }) ||
                      $app->model('template')->load({
                                                identifier => 'asset_insertion',
                                                type => 'custom',
                                                blog_id => [ $blog_id, 0 ]
                                               });
    if ($insert_tmpl) {
        $src = 'block';
    }
    $$tmpl =~ s/\*assetylene_options\*/$src/sg;
}

sub doLog {
    my ($msg) = @_; 
    return unless defined($msg);
    require MT::Log;
    my $log = MT::Log->new;
    $log->message($msg) ;
    $log->save or die $log->errstr;
}

1;
