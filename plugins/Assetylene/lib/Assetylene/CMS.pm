# This program is distributed under the terms of the
# GNU General Public License, version 2.
#
# $Id: CMS.pm 1534 2009-05-24 23:52:58Z breese $

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

# Caption >
    my $opt = $tmpl->createElement('app:setting', {
        id => 'image_caption',
        label => MT->translate('Caption'),
        label_class => 'no-header',
        hint => '',
        show_hint => 0,
    });

    require MT::Util;
    # Encode any special characters as HTML entities, since this
    # description is being placed in an HTML textarea:
    my $caption_safe = MT::Util::encode_html( $asset->description );

    # Contents of the app:setting tag:
    $opt->innerHTML(<<HTML);
    <input type="checkbox" id="insert_caption" name="insert_caption"
        value="1" />
    <label for="insert_caption"><__trans_section component="Assetylene"><__trans phrase='Insert a caption?'></__trans_section></label>
    <div class="textarea-wrapper"><textarea name="caption" style="height: 36px;" rows="2" cols=""
        onfocus="getByID('insert_caption').checked=true; return false;"
        class="full-width">$caption_safe</textarea></div>
HTML
    # Insert new field above the 'image_alignment' field:
    $tmpl->insertBefore($opt, $el);

#< Caption
# Pattern >

    $opt = $tmpl->createElement('app:setting', {
        id => 'asset_optins',
        label => MT->translate('Asset Options'),
        label_class => 'no-header',
        hint => '',
        show_hint => 0,
    });

    my $blog_id = $app->param('blog_id');
    my $plugin = MT->component("Assetylene");
    my $scope = "blog:".$blog_id;
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

#< Pattern
# lightbox >

    $opt = $tmpl->createElement('app:setting', {
        id => 'asset_lightbox',
        label => MT->translate('Lightbox'),
        label_class => 'no-header',
        hint => '',
        show_hint => 0,
    });

    use MT::Blog;
    my $blog = MT::Blog->load($blog_id) or die;
    my $themeid = $blog->theme_id;
    if ($themeid ne 'mtVicunaSimple') {

        my $insert_options = '';
        my $lb_select1 = $plugin->get_config_value('lb_select1',$scope);
        my $lightbox_selector1 = MT::Util::encode_html($plugin->get_config_value('lightbox_selector1',$scope),1);
        if (($lb_select1) && ($lightbox_selector1)) {
            $insert_options .= '<option value="' . $lightbox_selector1 . '">' . $lightbox_selector1 . '</option>' . "\n";
        }
        my $lb_select2 = $plugin->get_config_value('lb_select2',$scope);
        my $lightbox_selector2 = MT::Util::encode_html($plugin->get_config_value('lightbox_selector2',$scope),1);
        if (($lb_select2) && ($lightbox_selector2)) {
            $insert_options .= '<option value="' . $lightbox_selector2 . '">' . $lightbox_selector2 . '</option>' . "\n";
        }
        my $lb_select3 = $plugin->get_config_value('lb_select3',$scope);
        my $lightbox_selector3 = MT::Util::encode_html($plugin->get_config_value('lightbox_selector3',$scope),1);
        if (($lb_select3) && ($lightbox_selector3)) {
            $insert_options .= '<option value="' . $lightbox_selector3 . '">' . $lightbox_selector3 . '</option>' . "\n";
        }
        my $lb_select4 = $plugin->get_config_value('lb_select4',$scope);
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
                document.getElementById('create_thumbnail').checked=false;}"
                value="1"<mt:if name="make_thumb"> checked="checked" </mt:if> />
            <label for="insert_lightbox"><__trans_section component="Assetylene"><__trans phrase='Use Lightbox Effect'></__trans_section></label>
            <select id="insert_class" name="insert_class">
                $insert_options
            </select>
        </div>
HTML
    }
    $tmpl->insertBefore($opt, $el);
# < lightbox

    # Force the tokens of the template to be reprocessed now that
    # we've manipulated it:
    $tmpl->rescan();
}

sub asset_insert {
    my ($cb, $app, $param, $tmpl) = @_;

    my $blog_id = $app->param('blog_id');
    my $upload_html = $param->{ upload_html };
    use MT::Blog;
    my $blog = MT::Blog->load($blog_id) or die;
    my $themeid = $blog->theme_id;
    my $plugin = MT->component("Assetylene");
    my $scope = "blog:".$blog_id;
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
            }
            if ($cleanup_insert == '2') {
                $upload_html =~ s/ class=\"mt-image-none\"//i;
                $rightalign_class = ' class="'.$rightalign_class.'"';
                $upload_html =~ s/ class=\"mt-image-right\"/$rightalign_class/g;
                $leftalign_class = ' class="'.$leftalign_class.'"';
                $upload_html =~ s/ class=\"mt-image-left\"/$leftalign_class/g;
                if ($centeralign_class) {
                    $centeralign_class = ' class="'.$centeralign_class.'"';
                }
                $upload_html =~ s/ class=\"mt-image-center\"/$centeralign_class/g;
            } else {
                $upload_html =~ s/ class=\"mt-image-(none|right|left|center)\"//i;
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

    $param->{pattern} = $app->param('pattern');

    $insert_tmpl->param( $param );

    my $ctx = $insert_tmpl->context;
    $ctx->stash('blog', $blog);
    $ctx->stash('blog_id', $blog->id);
    $ctx->stash('local_blog_id', $blog->id);
    $ctx->stash('asset', $asset);

    # Process the user-defined template:
    my $new_html = $insert_tmpl->output;

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

sub doLog {
    my ($msg) = @_; 
    return unless defined($msg);
    require MT::Log;
    my $log = MT::Log->new;
    $log->message($msg) ;
    $log->save or die $log->errstr;
}

1;
