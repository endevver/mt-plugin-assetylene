Assetylene, a plugin for Movable Type
======================================

This plugin provides a new "Caption" field when inserting an asset into a
post, and the ability to customize the HTML markup produced for publishing MT
assets.

Usage
------

You can create a custom template module, named "Asset Insertion", and that
template will then be used to create the HTML for any asset you embed
into a post.

There are a number of template variables made available to this template:

* upload_html: This is the original markup MT constructed for the
inserted asset.
* enclose: 1 or 0, depending on whether the asset is to be wrapped with a
'form' tag.
* include: 1 or 0, depending on whether the image is to be displayed or
simply linked to.
* thumb: 1 or 0, depending on whether the inline image is a thumbnail
of the original.
* align: The value of the alignment option ('none', 'left', 'right',
'center').
* popup: 1 or 0, depending on whether the thumbnail image is linked
to a popup of the full image.
* caption: The value entered for the caption on the insert options dialog.
* label: The 'label' value of the asset being inserted.
* description: The 'description' value of the asset being inserted.
* asset_id: The numeric ID of the asset being inserted.
* form_tag: The opening HTML form tag MT creates to enclose the
asset. If you output this, be sure to add a closing form tag
as well.
* form_class: The CSS class name(s) applied to the form tag.
* form_style: The CSS styling applied to the form tag.
* img_tag: The MT-constructed img tag being inserted (this is unset
if no image is actually inserted and linked to instead).
* img_alt: The "alt" attribute of the inserted image.
* img_height: The numeric height of the inserted image.
* img_width: The numeric width of the inserted image.
* img_src: The url of the inserted image.
* img_style: Any CSS styling applied to the inline image.
* img_class: Any CSS class name(s) applied to the inline image.
* a_tag: The "a" tag produced to link the image (if any).
* a_href: The "href" attribute value of the "a" tag.
* a_onclick: The "onclick" attribute value of the "a" tag.

Also, the asset itself is in context, so any of the MT Asset tags may be
used to generate the asset markup. And the current blog is also in context.

An example template can be found in:

    plugins/Assestylene/template/asset_insertion.mtml

You can use this as a basis for your own custom template.

Or use tenplate install plugin such as Templets and  TemplateImport.

    https://github.com/ogawa/mt-plugin-Templets

    https://github.com/yuji/mt-plugin-TemplateImport

Installation
-------------

To install this plugin, drop the files included with this plugin into your
Movable Type directory (under the mt-static/plugins/Assetylene,
plugins/Assetylene locations).

License
--------

This plugin has been released under the terms of the GNU Public License,
version 2.0.
