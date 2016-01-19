# Assetylene, a plugin for Movable Type

This plugin provides a new "Caption" field when inserting an asset into a post,
and the ability to customize the HTML markup produced for publishing MT assets.

Note that Assetylene 2.0.0 is very different from 1.x, to work with Movable Type
6.2.2 and later. **If upgrading, your Asset Insertion Template Module will need
to be updated to work with Assetylene.**


# Prerequisites

* Movable Type 6.2 or later
* Movable Type 4.2 or later, 5.x, 6.0.x, and 6.1.x are supported with
  [version 1.1.1](https://github.com/endevver/mt-plugin-assetylene/releases) of
  Assetylene.

# Installation

To install this plugin follow the instructions found here:

http://tinyurl.com/easy-plugin-install


# Usage

This plugin adds a "Caption" checkbox and field to the asset Insert Options
dialog. The caption field can of course be edited, but is pre-populated with the
value of the asset's Description field. Note that selecting the "Caption"
checkbox enabled/disabled display of the caption; the text doesn't need to be
deleted from the caption field if you don't want it displayed.

After creating the Asset Insertion Template Module and customizing it as
necessary, no further interaction from the author is necessary to use the new
template during the asset insert process.


# Template  and Template Tags

Create a Template Module named "Asset Insertion", and that template will then
be used to create the HTML for any asset you embed into a post.

Assetylene adds a number of template tags that can be used in the Asset
Insertion Template Module. These tags reflect options that are set on the asset
Insert Options screen.

* `mt:AssetyleneAlign`: The value of the "Alignment" field, either `none`,
  `left`, `center`, or `right`.
* `mt:AssetyleneCaption`: The value of the caption field, if the "Insert a
  caption?" checkbox is selected.
* `mt:AssetyleneEnclose`: This value is used to track whether the asset inserter
  is being used with an Asset Custom Field. If a Custom Field is being used then
  this value is true, otherwise false.
* `mt:AssetyleneInclude`: This value is true if the "Display Image in
  entry/page" checkbox is selected; false otherwise.
* `mt:AssetyleneNewEntry`: This value is true if the asset is being inserted
  into a new and unsaved Entry or Page, otherwise false.
* `mt:AssetylenePopup`: This value is true if the "Link image to full-size
  version in a popup window" checkbox is selected; false otherwise.
* `mt:AssetyleneThumb`: This value is true if the "Use thumbnail" checkbox is
  selected; false otherwise.
* `mt:AssetyleneThumbWidth`: This is the "width: [ ] pixels" value for the
  thumbnail.
* `mt:AssetyleneWrapText`: This value is always true.

Assetylene provides one more tag: `mt:AssetyleneDefaultHTML`. This tag uses the
above tag values to build the default HTML created by Movable Type.

Additionally, the Asset Insertion Template Module should use the Assets block
tag to enter asset context of the assets selected for inserting. The example
template shows this in use:

    <div class="assets">
    <mt:Assets><mt:Section strip_linefeeds="1" replace="    ","">
        <mt:If tag="AssetyleneCaption">
            <div class="caption align-<mt:AssetyleneAlign>">
            <mt:If tag="AssetyleneThumb">
                <mt:AssetyleneThumbWidth setvar="thumb_width">
                <img src="<mt:AssetThumbnailURL width="$thumb_width">" alt="<mt:AssetLabel>" />
            <mt:Else>
                <img src="<mt:AssetURL>" alt="<mt:AssetLabel>" />
            </mt:If>
                <div><mt:AssetyleneCaption></div>
            </div>
        <mt:Else>
            <mt:AssetyleneDefaultHTML>
        </mt:If>
    </mt:Section>
    </mt:Assets></div>

Note the use of the `Section` tag and arguments, and the different spacing of
the `Assets`, `Section`, and closing `div.assets` tags. All of this is to
format the inserted HTML, minimizing space used but still somewhat maintaining
readability.


# Credit

Brad Choate originally created this plugin for Six Apart in December 2008
(version 1.0). Byrne Reese made some updates in May 2009 (version 1.01 and
1.02). Since being imported to Github in 2010, Endevver has maintained this
plugin with commits from Dan Wolfgang.


# License

This plugin has been released under the terms of the GNU Public License,
version 2.0.
