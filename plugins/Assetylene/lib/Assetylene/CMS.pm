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
    my $opt;
# Without Link Max Original Size >
    my $resize_link = $plugin->get_config_value('resize_link',$scope) || 0;
    my $resize_check = $resize_link ? 'hidden' : 'checkbox';
    my $readonly_w = $resize_link ? ' readonly="readonly"' : '';
    my $readonly_h = $resize_link ? ' readonly="readonly"' : '';
    my $show_input = $resize_link ? 'show();' : 'hide();';
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
    <span id="without">
        <input type="checkbox" id="without_link" name="without_link" value="1" />
        <label for="without_link"><__trans_section component="Assetylene"><__trans phrase='Insert without Link'></__trans_section></label>
    </span>
    <span id ="max_size-select">
        <input type="$resize_check" id="resize_link" name="resize_link" value="1" />
        <label><__trans_section component="Assetylene"><__trans phrase='Resize Link'></__trans_section></label>
    </span>
    <span id="max_size-input">
        <label for="max_link_width"><__trans_section component="Assetylene"><__trans phrase='Max Link Size'></__trans_section></label>
        <input type="text" id="max_link_width" name="max_link_width" value="$max_link_width" style="width:8em;"$readonly_w /> x 
        <input type="text" id="max_link_height" name="max_link_height" value="$max_link_height" style="width:8em;"$readonly_h />
    </span>
    <script type="text/javascript">
    jQuery(document).ready(function(){
        if (jQuery('#create_thumbnail').attr('checked') == false) {
            jQuery('#max_size-field').hide();
            if (jQuery('#asset_lightbox-field')) {
                jQuery('#asset_lightbox-field').hide();
            }
            if (jQuery('#insert_lightbox-field')) {
                jQuery('#insert_lightbox-field').hide();
            }
        } else {
            if (jQuery('#asset_lightbox-field')) {
                jQuery('#asset_lightbox-field').show();
            }
            if (jQuery('#insert_lightbox-field')) {
                jQuery('#insert_lightbox-field').show();
            }
        }
        jQuery('#create_thumbnail').click(function() {
            if (jQuery('#create_thumbnail').attr('checked') == true) {
                jQuery('#max_size-field').show();
                if (jQuery('#asset_lightbox-field')) {
                    jQuery('#asset_lightbox-field').show();
                }
                if (jQuery('#insert_lightbox-field')) {
                    jQuery('#insert_lightbox-field').show();
                }
            } else {
                jQuery('#max_size-field').hide();
                if (jQuery('#asset_lightbox-field')) {
                    jQuery('#asset_lightbox-field').hide();
                }
                if (jQuery('#insert_lightbox-field')) {
                    jQuery('#insert_lightbox-field').hide();
                }
            }
        });
        jQuery('#max_size-input').$show_input
        jQuery('#without_link').click(function() {
            if (jQuery('#without_link').attr('checked') == true) {
                if (jQuery('#asset_lightbox-field')) {
                    jQuery('#asset_lightbox-field').hide();
                }
                if (jQuery('#insert_lightbox-field')) {
                    jQuery('#insert_lightbox-field').hide();
                }
                jQuery('#max_size-select').hide();
                jQuery('#max_size-input').hide();
            } else {
                if (jQuery('#asset_lightbox-field')) {
                    jQuery('#asset_lightbox-field').show();
                }
                if (jQuery('#insert_lightbox-field')) {
                    jQuery('#insert_lightbox-field').show();
                }
                jQuery('#max_size-select').show();
                if (jQuery('#max_size-select').attr('checked') == true) {
                    jQuery('#max_size-input').show();
                }
            }
        });
        jQuery('#resize_link').click(function() {
            if (jQuery('#resize_link').attr('checked') == true) {
                jQuery('#max_size-input').show();
                jQuery('#without').hide();
                jQuery('#create_thumbnail').attr('checked', true);
            } else {
                jQuery('#max_size-input').hide();
                jQuery('#without').show();
            }
        });
    });
    </script>
HTML
    $tmpl->insertBefore($opt, $el);
#< Max Original Size
# lightbox >
    $opt = $tmpl->createElement('app:setting', {
        id => 'asset_lightbox',
        label => MT->translate('Lightbox'),
        label_class => 'no-header',
        hint => '',
        show_hint => 0,
    });
    my $vicuna = MT->component( 'mtVicunaSimple' );
    my $themeid = $blog->theme_id;
    if ((!$vicuna) || ($themeid ne 'mtVicunaSimple')) {
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
                onclick="if(this.checked){
                  jQuery('#create_thumbnail').attr('checked', true);
                  jQuery('#without').hide();
                }else{
                  jQuery('#without').show();
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
# Pattern >
    if ($insert_tmpl) {
        my $jquery_insert1 = '';
        if ($plugin->get_config_value('remove_width1',$scope) || 0) {
            $jquery_insert1 .= "jQuery('#create_thumbnail-field').hide();\n";
        } else {
            $jquery_insert1 .= "jQuery('#create_thumbnail-field').show();\n";
        }
        if ($plugin->get_config_value('remove_caption1',$scope) || 0) {
            $jquery_insert1 .= "          jQuery('#asset_options-field').hide();\n";
        } else {
            $jquery_insert1 .= "          jQuery('#asset_options-field').show();\n";
        }
        if ($plugin->get_config_value('remove_lightbox1',$scope) || 0) {
            $jquery_insert1 .= "          jQuery('#asset_lightbox-field').hide();\n";
        } else {
            $jquery_insert1 .= "          jQuery('#asset_lightbox-field').show();\n";
        }
        if ($plugin->get_config_value('remove_width1',$scope) || 0) {
            $jquery_insert1 .= "          jQuery('#image_alignment-field').hide();\n";
        } else {
            $jquery_insert1 .= "          jQuery('#image_alignment-field').show();\n";
        }
        my $jquery_insert2 = '';
        if ($plugin->get_config_value('remove_width2',$scope) || 0) {
            $jquery_insert2 .= "jQuery('#create_thumbnail-field').hide();\n";
        } else {
            $jquery_insert2 .= "jQuery('#create_thumbnail-field').show();\n";
        }
        if ($plugin->get_config_value('remove_caption2',$scope) || 0) {
            $jquery_insert2 .= "          jQuery('#asset_options-field').hide();\n";
        } else {
            $jquery_insert2 .= "          jQuery('#asset_options-field').show();\n";
        }
        if ($plugin->get_config_value('remove_lightbox2',$scope) || 0) {
            $jquery_insert2 .= "          jQuery('#asset_lightbox-field').hide();\n";
        } else {
            $jquery_insert2 .= "          jQuery('#asset_lightbox-field').show();\n";
        }
        if ($plugin->get_config_value('remove_width2',$scope) || 0) {
            $jquery_insert2 .= "          jQuery('#image_alignment-field').hide();\n";
        } else {
            $jquery_insert2 .= "          jQuery('#image_alignment-field').show();\n";
        }
        my $jquery_insert3 = '';
        if ($plugin->get_config_value('remove_width3',$scope) || 0) {
            $jquery_insert3 .= "jQuery('#create_thumbnail-field').hide();\n";
        } else {
            $jquery_insert3 .= "jQuery('#create_thumbnail-field').show();\n";
        }
        if ($plugin->get_config_value('remove_caption3',$scope) || 0) {
            $jquery_insert3 .= "          jQuery('#asset_options-field').hide();\n";
        } else {
            $jquery_insert3 .= "          jQuery('#asset_options-field').show();\n";
        }
        if ($plugin->get_config_value('remove_lightbox3',$scope) || 0) {
            $jquery_insert3 .= "          jQuery('#asset_lightbox-field').hide();\n";
        } else {
            $jquery_insert3 .= "          jQuery('#asset_lightbox-field').show();\n";
        }
        if ($plugin->get_config_value('remove_width3',$scope) || 0) {
            $jquery_insert3 .= "          jQuery('#image_alignment-field').hide();\n";
        } else {
            $jquery_insert3 .= "          jQuery('#image_alignment-field').show();\n";
        }
        my $jquery_insert4 = '';
        if ($plugin->get_config_value('remove_width4',$scope) || 0) {
            $jquery_insert4 .= "jQuery('#create_thumbnail-field').hide();\n";
        } else {
            $jquery_insert4 .= "jQuery('#create_thumbnail-field').show();\n";
        }
        if ($plugin->get_config_value('remove_caption4',$scope) || 0) {
            $jquery_insert4 .= "          jQuery('#asset_options-field').hide();\n";
        } else {
            $jquery_insert4 .= "          jQuery('#asset_options-field').show();\n";
        }
        if ($plugin->get_config_value('remove_lightbox4',$scope) || 0) {
            $jquery_insert4 .= "          jQuery('#asset_lightbox-field').hide();\n";
        } else {
            $jquery_insert4 .= "          jQuery('#asset_lightbox-field').show();\n";
        }
        if ($plugin->get_config_value('remove_width4',$scope) || 0) {
            $jquery_insert4 .= "          jQuery('#image_alignment-field').hide();\n";
        } else {
            $jquery_insert4 .= "          jQuery('#image_alignment-field').show();\n";
        }
        my $jquery_insert5 = '';
        if ($plugin->get_config_value('remove_width5',$scope) || 0) {
            $jquery_insert5 .= "jQuery('#create_thumbnail-field').hide();\n";
        } else {
            $jquery_insert5 .= "jQuery('#create_thumbnail-field').show();\n";
        }
        if ($plugin->get_config_value('remove_caption5',$scope) || 0) {
            $jquery_insert5 .= "          jQuery('#asset_options-field').hide();\n";
        } else {
            $jquery_insert5 .= "          jQuery('#asset_options-field').show();\n";
        }
        if ($plugin->get_config_value('remove_lightbox5',$scope) || 0) {
            $jquery_insert5 .= "          jQuery('#asset_lightbox-field').hide();\n";
        } else {
            $jquery_insert5 .= "          jQuery('#asset_lightbox-field').show();\n";
        }
        if ($plugin->get_config_value('remove_width5',$scope) || 0) {
            $jquery_insert5 .= "          jQuery('#image_alignment-field').hide();\n";
        } else {
            $jquery_insert5 .= "          jQuery('#image_alignment-field').show();\n";
        }

        $opt = $tmpl->createElement('app:setting', {
            id => 'insert_options',
            label => MT->translate('Insert Options'),
            label_class => 'no-header',
            hint => '',
            show_hint => 0,
        });
        my $insert_options = '';
        my $default_pattern = $plugin->get_config_value('default_pattern',$scope) || 1;
        my $pattern_name1 = MT::Util::encode_html($plugin->get_config_value('pattern1',$scope),1);
        if ($pattern_name1) {
            $insert_options .= '<option value="1"';
            if ($default_pattern == 1) {
              $insert_options .= ' selected="selected"';
            }
            $insert_options .= '>' . $pattern_name1 . '</option>' . "\n";
        }
        my $pattern_name2 = MT::Util::encode_html($plugin->get_config_value('pattern2',$scope),1);
        if ($pattern_name2) {
            $insert_options .= '<option value="2"';
            if ($default_pattern == 2) {
              $insert_options .= ' selected="selected"';
            }
            $insert_options .= '>' . $pattern_name2 . '</option>' . "\n";
        }
        my $pattern_name3 = MT::Util::encode_html($plugin->get_config_value('pattern3',$scope),1);
        if ($pattern_name3) {
            $insert_options .= '<option value="3"';
            if ($default_pattern == 3) {
              $insert_options .= ' selected="selected"';
            }
            $insert_options .= '>' . $pattern_name3 . '</option>' . "\n";
        }
        my $pattern_name4 = MT::Util::encode_html($plugin->get_config_value('pattern4',$scope),1);
        if ($pattern_name4) {
            $insert_options .= '<option value="4"';
            if ($default_pattern == 4) {
              $insert_options .= ' selected="selected"';
            }
            $insert_options .= '>' . $pattern_name4 . '</option>' . "\n";
        }
        my $pattern_name5 = MT::Util::encode_html($plugin->get_config_value('pattern5',$scope),1);
        if ($pattern_name5) {
            $insert_options .= '<option value="5"';
            if ($default_pattern == 5) {
              $insert_options .= ' selected="selected"';
            }
            $insert_options .= '>' . $pattern_name5 . '</option>' . "\n";
        }
        if ($insert_options) {
            $opt->innerHTML(<<HTML);
    <label for="pattern"><__trans_section component="Assetylene"><__trans phrase='Insertion Pattern'></__trans_section></label>
    <select name="pattern" id="pattern">
        $insert_options
    </select><br />
    <script type="text/javascript">
    jQuery(document).ready(function(){
      jQuery('select#pattern').change(function () {
        var str = jQuery('select option:selected').val();
        if (str == 1) {
          $jquery_insert1
        } else if (str == 2) {
          $jquery_insert2
        } else if (str == 3) {
          $jquery_insert3
        } else if (str == 4) {
          $jquery_insert4
        } else if (str ==5) {
          $jquery_insert5
        }
      }).change();
    });
    </script>
HTML
            $tmpl->insertBefore($opt, $el);
        }
    }
#< Pattern
# Caption >
    $opt = $tmpl->createElement('app:setting', {
        id => 'asset_options',
        label => MT->translate('Asset Options'),
        label_class => 'no-header',
        hint => '',
        show_hint => 0,
    });
    require MT::Util;
    # Encode any special characters as HTML entities, since this
    # description is being placed in an HTML textarea:
    my $caption_safe = MT::Util::encode_html( $asset->description )
                    || MT::Util::encode_html( $asset->label );

    if ($insert_tmpl) {
        $opt->innerHTML(<<HTML);
<div class="field">
    <input type="checkbox" id="insert_caption" name="insert_caption" value="1" />
    <label for="insert_caption"><__trans_section component="Assetylene"><__trans phrase='Insert a caption?'></__trans_section></label>
    <div class="textarea-wrapper"><textarea name="caption" style="height: 36px;" rows="2" cols="60"
        onfocus="getByID('insert_caption').checked=true; return false;"
        class="full-width">$caption_safe</textarea></div>
    <input type="hidden" name="save_as" value="description" />
</div>
HTML
    }
    else {
        $opt->innerHTML(<<HTML);
<div class="field">
    <input type="checkbox" id="insert_caption" name="insert_caption" value="1" />
    <label for="insert_caption"><__trans_section component="Assetylene"><__trans phrase='Set alt attribute in image?'></__trans_section></label>
    <input type="text" name="caption" onfocus="getByID('insert_caption').checked=true; return false;"
        value="$caption_safe" style="width:16em;" />&nbsp;<__trans_section component="Assetylene"><__trans phrase='and Save as'></__trans_section>
    <select name="sava_as">
        <option value=""><__trans phrase='None'></option>
        <option value="label"><__trans phrase='Label'></option>
        <option value="description"><__trans phrase='Description'></option>
    </select>
</div>
HTML
    }
    $tmpl->insertBefore($opt, $el);
#< Caption
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
    use MT::Blog;
    my $blog = MT::Blog->load($blog_id) or die;
    my $themeid = $blog->theme_id;
    my $plugin = MT->component("Assetylene");
    my $scope = "blog:".$blog_id;

    my $upload_html = $param->{ upload_html };
    my ($html_img_tag) = $upload_html =~ /(<img\b[^>]+?>)/s;
    my ($html_img_src) = $html_img_tag =~ /\bsrc="([^\"]+)"/s;
    my ($html_a_tag) = $upload_html =~ /(<a\b[^>]+?>)/s;
    my ($html_a_href) = $html_a_tag =~ /\bhref="(.+?)"/s;

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

    my $original = $tmpl->context->stash('asset')
      or return;

    unless ((MT->config('DisableCleanup') || 0) || ($themeid eq 'mtVicunaSimple')){
        my $cleanup_insert = $plugin->get_config_value('cleanup_insert',$scope) || 0;
        if ($cleanup_insert) {
            my $rightalign_class = $plugin->get_config_value('rightalign_class',$scope);
            my $centeralign_class = $plugin->get_config_value('centeralign_class',$scope);
            my $leftalign_class = $plugin->get_config_value('leftalign_class',$scope);
            my $wrap;
            if (($cleanup_insert == 1)||($cleanup_insert == 4)) {
                $wrap = ($cleanup_insert == 1) ? '<p' : '<div';
                if ($upload_html =~ / class=\"mt-image-left\"/) {
                    $wrap .= ' class="'.$leftalign_class.'">';
                }
                if ($upload_html =~ / class=\"mt-image-right\"/) {
                    $wrap .= ' class="'.$rightalign_class.'">';
                }
                if ($upload_html =~ / class=\"mt-image-center\"/) {
                    if ($centeralign_class) {
                        $wrap .= ' class="'.$centeralign_class.'">';
                    } else {
                        $wrap .= '>';
                    }
                }
                $upload_html =~ s/ class=\"mt-image-(none|right|left|center)\"//g;
            }
            if ($cleanup_insert == 2) {
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
            if ($cleanup_insert) {
                $upload_html =~ s/ style=\"\"//i;
                $upload_html =~ s/ style=\"float\: (right|left)\; margin\: 0 (0|20px) 20px (0|20px)\;\"//i;
                $upload_html =~ s/ style=\"text-align\: center\; display\: block\; margin\: 0 auto 20px\;\"//i;
            }
            if ($wrap) {
                if ($cleanup_insert == 1) {
                    $upload_html = $wrap . $upload_html . '</p>';
                } else {
                    $upload_html = $wrap . $upload_html . '</div>';
                }
            }
        }
    }
    if ($themeid ne 'mtVicunaSimple') {
        my $insert_class = $app->param('insert_class');
        if ( $app->param('insert_lightbox') ) {
            $insert_class = '<a '.$insert_class;
            $upload_html =~ s/<a/$insert_class/g;
        }
    }

    if ($app->param('insert_caption')) {
        my $caption_text = $app->param('caption')||'';
        unless ($insert_tmpl) {
            my $alt_caption = ' alt="' . $caption_text . '"';
            $upload_html =~ s/\salt="[^"]*"/$alt_caption/g;
        }
        if ($caption_text) {
            if ($app->param('sava_as') eq 'label') {
                $original->label($caption_text);
                $original->save;
            } else {
                $original->description($caption_text);
                $original->save;
            }
        }
    }

    if ($app->param('without_link')) {
        $upload_html =~ s/^.*(<img [^>]+>).*$/$1/;
    }

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
    my $updated = mt->model('asset')->load($original->id)
      or return;

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

        $param->{label} = $updated->label;
        $param->{description} = $updated->description;
        $param->{asset_id} = $updated->id;

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
        $ctx->stash('asset', $updated);

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
    my $insertion = 'block';
    my $lightbox_disp;
    my $blog_id = $app->param('blog_id')
      or return;
    my $blog = $app->blog
      or return;
    return unless ($blog_id == $blog->id);
    my $insert_tmpl = $app->model('template')->load({
                                                name => 'Asset Insertion',
                                                type => 'custom',
                                                blog_id => $blog_id
                                               }) ||
                      $app->model('template')->load({
                                                identifier => 'asset_insertion',
                                                type => 'custom',
                                                blog_id => $blog_id
                                               });
    my $global_tmpl = $app->model('template')->load({
                                                name => 'Asset Insertion',
                                                type => 'custom',
                                                blog_id => 0
                                               }) ||
                      $app->model('template')->load({
                                                identifier => 'asset_insertion',
                                                type => 'custom',
                                                blog_id => 0
                                               });
    if ($insert_tmpl) {
        $src = 'block';
        $insertion = 'none';
    }
    if ($global_tmpl) {
        $src = 'block';
    }

    my $install_url = '?__mode=install_blog_templates&amp;blog_id=' . $blog_id;
    $install_url .= '&amp;magic_token=' . $app->current_magic;

    if ((!MT->component( 'mtVicunaSimple' )) || ($blog->theme_id ne 'mtVicunaSimple')) {
        $lightbox_disp = 'block;';
    } else {
        $lightbox_disp = 'none;';
    }
        
    $$tmpl =~ s/\*assetylene_options\*/$src/sg;
    $$tmpl =~ s/\*module_installed\*/$insertion/sg;
    $$tmpl =~ s/\*module_install_url\*/$install_url/sg;
    $$tmpl =~ s/\*lightbox\*/$lightbox_disp/sg;

}

sub install_blog_templates {
    my $app = shift;
    my $blog_id = $app->param('blog_id')
      or return MT->translate( 'Invalid request.' );
    my $blog = MT->model('blog')->load($blog_id)
      or return MT->translate( 'Invalid request.' );
    $app->validate_magic()
      or return MT->translate( 'Permission denied.' );
    my $user = $app->user
      or return;
    if (! is_user_can( $blog, $user, 'edit_templates' ) ) {
        return MT->translate( 'Permission denied.' );
    }
    my $insert_tmpl = MT->model('template')->load({
                                                name => 'Asset Insertion',
                                                type => 'custom',
                                                blog_id => $blog_id
                                               }) ||
                      MT->model('template')->load({
                                                identifier => 'asset_insertion',
                                                type => 'custom',
                                                blog_id => $blog_id
                                               });
    return MT->translate( 'Already installed.' ) if ($insert_tmpl);
    my $plugin = MT->component("Assetylene");
    my $path = $plugin->path . "/template/";
    opendir DH, $path
      or return $app->error($plugin->translate('Open directory error'));
    my $fmgr = $blog->file_mgr;
    my $file_name = $path . 'asset_insertion.mtml';
    my $template_text =$fmgr->get_data($file_name)
      or return MT->translate( 'Open file error.' );
    $template_text = MT::I18N::encode_text($template_text, 'utf8', $app->charset)
      if (defined($template_text));
    my $template = MT->model('template')->new
      or return MT->translate( 'Create template error.' );
    $template->blog_id($blog_id);
    $template->created_by($user->id);
    $template->identifier('asset_insertion');
    $template->name('Asset Insertion');
    $template->type('custom');
    $template->text($template_text);
    $template->save
      or return;
    my $cgi = $app->{cfg}->CGIPath . $app->{cfg}->AdminScript;
    $app->redirect( "$cgi?__mode=list_template&blog_id=$blog_id&saved=1" );
}

sub install_global_templates {
    #$app->redirect( "$cgi?__mode=list_template&blog_id=0" );
}

sub is_user_can {
    my ( $blog, $user, $permission ) = @_;
    $permission = 'can_' . $permission;
    my $perm = $user->is_superuser;
    unless ( $perm ) {
        if ( $blog ) {
            my $admin = 'can_administer_blog';
            $perm = $user->permissions( $blog->id )->$admin;
            $perm = $user->permissions( $blog->id )->$permission unless $perm;
        } else {
            $perm = $user->permissions()->$permission;
        }
    }
    return $perm;
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
