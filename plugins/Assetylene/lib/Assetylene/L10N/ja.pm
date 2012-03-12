package Assetylene::L10N::ja;

use strict;
use base 'Assetylene::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
	'Provides a new "Caption" field when inserting an asset into a post, and the ability to customize the HTML markup produced for publishing MT assets.'
	   => 'キャプション・フィールドの追加と、アイテムのマークアップをカスタマイズする機能を提供します。',
	'Sample "Asset Insertion" template module.'
	   => '"Asset Insertion"テンプレートモジュールのサンプルです。',
	'This module used by Assetylene plugin.'
	   => 'このモジュールは Assetylene プラグインにより使用されます。',
	'Sample "Asset Insertion" module for Assetylene. This is a templete module. Not a Template Set.'
	   => 'Assetylene プラグインにより使用される"Asset Insertion"モジュールのサンプルです。テンプレートモジュールのみです。テンプレートセットではありません。',
	'AssetInsertion for Assetylene' => 'Assetyleneプラグイン用"Asset Insertion"モジュール',
	'Insert a caption?' => 'キャプションを挿入',
	'Set alt attribute in image?' => '表示画像のalt属性を指定',
	'Asset Insertion' => 'アイテムを挿入する',
	'Use Lightbox Effect' => 'Lightbox効果を使用する',
	'CleanUp Asset Insert' => 'アイテム挿入を<br />クリーンアップする',
	'No CleanUp' => 'クリーンアップしない',
	'Add Class for Wrap Paragraph tag' => 'pタグで囲み、クラスを追加する',
	'Add Class for Image tag' => 'imgタグにクラスを追加する',
	'Alignment Class' => '位置揃えクラス',
	'Lightbox Selector' => 'Lightboxセレクター',
	'RightAlign' => '右揃え',
	'CenterALign' => '中央揃え',
	'LeftAlign' => '左揃え',
	'Use' => '使用する',
	'Remove Blank' => '空白行を削除',
	'Pass' => '行わない',
	'Insertion Pattern' => '挿入パターン',
	'Limit Image Size' => '画像サイズの制限',
	'Limit Thumbnail Width' => 'サムネイルの幅を制限',
	'Limit Thumbnail Height' => 'サムネイルの高さを制限',
	'Limit Image Width' => '画像の幅を制限',
	'Limit Image Height' => '画像の高さを制限',
	'Remove Popup Insert' => 'ポップアップウィンドウ<br />での挿入を削除する',
	'Limit size of Link Image' => 'リンク画像のサイズ制限',
	'Limited in' => '制限する',
	'Max size of Link Image' => 'リンク画像の最大サイズ',
	'Insert without Link' => 'リンク無しで挿入',
	'Resize Link' => 'リンクを縮小する',
	'Max Link Size' => 'リングサイズの最大値',
	'Prefs of Asset Insertion module.' => 'アイテム挿入モジュールの設定',
	'remove width' => '幅入力を削除',
	'remove caption' => 'キャプション入力を削除',
	'remove lightbox' => 'lightbox指定を削除',
	'remove align' => '配置を削除',
);

1;
