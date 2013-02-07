# This program is distributed under the terms of the
# GNU General Public License, version 2.
#
# $Id: CMS.pm 1534 2009-05-24 23:52:58Z breese $

package Assetylene::CMS;

use strict;
use warnings;

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

    my $opt = $tmpl->createElement('app:setting', {
        id          => 'image_caption',
        label       => MT->translate('Caption'),
        label_class => 'no-header',
    });

    require MT::Util;
    # Encode any special characters as HTML entities, since this
    # description is being placed in an HTML textarea:
    my $caption_safe = MT::Util::encode_html( $asset->description );

    # Contents of the app:setting tag:
    $opt->innerHTML(<<HTML);
    <input type="checkbox"
        id="insert_caption"
        name="insert_caption"
        value="1" />
    <label for="insert_caption">Insert a caption?</label>
    <div class="textarea-wrapper" style="margin-top: 3px;">
        <textarea name="caption"
            style="height: <mt:If tag="Version" lt="5">36<mt:Else>42</mt:If>px;"
            onfocus="getByID('insert_caption').checked=true; return false;"
            class="text full full-width">$caption_safe</textarea>
    </div>
HTML

    # Insert new field above the 'image_alignment' field:
    $tmpl->insertBefore($opt, $el);
    # Force the tokens of the template to be reprocessed now that
    # we've manipulated it:
    $tmpl->rescan();
}

sub asset_insert {
    my ($cb, $app, $param, $tmpl) = @_;

    my $blog = $app->blog;

    # Assertions:
    # Load the user-defined "Asset Insertion" template module.
    # Currently, this template must be named in English. Look both
    # at the blog and system level for this template.
    my $insert_tmpl = $app->model('template')->load({
        name => 'Asset Insertion', type => 'custom',
        blog_id => [ $blog->id, 0 ] });
    return unless $insert_tmpl;

    my $asset = $tmpl->context->stash('asset');

    # Collect all the elements of the MT generated asset markup
    # so they can be manipulated indepdendently by the user-defined
    # template:
    my $html = $param->{upload_html};
    my ($img_tag) = $html =~ /(<img\b[^>]+?>)/s;
    my ($a_tag) = $html =~ /(<a\b[^>]+?>)/s;
    my ($form_tag) = $html =~ /(<form[^>]+?>)/s;

    $param->{enclose} = 1 if $form_tag;
    $param->{include} = 1 if $app->param('include');
    $param->{thumb} = 1 if $app->param('thumb');
    ($param->{align}) = $app->param('align') =~ m/(\w+)/;
    $param->{caption} = $app->param('insert_caption') ? $app->param('caption') : '';
    $param->{popup} = 1 if $app->param('popup');

    $param->{label} = $asset->label;
    $param->{description} = $asset->description;
    $param->{asset_id} = $asset->id;

    $param->{a_tag} = $a_tag;
    ($param->{a_href}) = $a_tag =~ /\bhref="(.+?)"/s;
    ($param->{a_onclick}) = $a_tag =~ /\bonclick="(.+?)"/s;

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

    $insert_tmpl->param( $param );

    my $ctx = $insert_tmpl->context;
    $ctx->stash('blog', $blog);
    $ctx->stash('blog_id', $blog->id);
    $ctx->stash('local_blog_id', $blog->id);
    $ctx->stash('asset', $asset);

    # Process the user-defined template:
    my $new_html = $insert_tmpl->output;

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

1;
