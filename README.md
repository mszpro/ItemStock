#  Item Stock for Mac OS

<img width="500" alt="image" src="/github-image.png">

Stock is a MacOS menu bar app that helps you quickly save a web link, a file link, or a text by using drag and drop.
You can simply drag a link from a web page, a file from Finder, or a selcted text into the icon on the system bar, and it will be saved.
You can also search for an item, tag an item, and more (get an iCloud link if the file is located in your iCloud Drive).

これはウェブリンク、ファイルリンク、テキストをドラッグアンドドロップですばやく保存するMac OSメニューバーアプリです。

ウェブページ内のリンク、Finder内のファイル、選択したテキストが、ドラッグしてシステムバーのアイコンにドロップするだけで保存されます。

アイテムを検索したり、アイテムにタグ付けをしたりといったこともできます（iCloud Driveにファイルがある場合はiCloudのリンクも入手できます）。

## Installation

### App Store

このアプリは、 App Store から直接ダウンロードできます。

<a href="https://apps.apple.com/jp/app/%E3%82%A2%E3%82%A4%E3%83%86%E3%83%A0-%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF/id1569290801?mt=12&amp;itsct=apps_box_badge&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-top-left-radius: 13px; border-top-right-radius: 13px; border-bottom-right-radius: 13px; border-bottom-left-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-mac-app-store/black/en-us?size=250x83&amp;releaseDate=1621987200&h=29dc1b06c246da8a51f206df8657ab77" alt="Download on the Mac App Store" style="border-top-left-radius: 13px; border-top-right-radius: 13px; border-bottom-right-radius: 13px; border-bottom-left-radius: 13px; width: 250px; height: 83px;"></a>

### Build with Xcode

You can also clone this git repository, open it in Xcode, and run this app on your computer.
また、コンピューターでこのgitリポジトリのクローンを作成してXcodeで開き、このアプリを起動することも可能です。

## How to use?

Simply drag a link, file, or text into the icon on the system bar.

Click on the icon to see a list of items.
You can scroll to view all the items.

Click on the icon to open an item.

Click on the `...` button on the right of an item to view actions.
If you want to add a tag to an item, use the `Edit` optionfrom that menu.

リンク、ファイル、またはテキストをシステムバーのアイコンにドラッグするだけです。

アイコンをクリックすると、アイテムの一覧が表示されます。
スクロールしてすべてのアイテムを見ることができます。

アイコンをクリックすると、アイテムを開くことができます。

アイテムの右側にある「...」ボタンをクリックすると、アクションが表示されます。
アイテムにタグを追加したい場合は、そのメニューの「編集」を選択します。

## Contribution

I will be happy if you contribute.

Suggest a feature: [New Issue](https://github.com/mszpro/ItemStock/issues/new)
[New Pull Request](https://github.com/mszpro/ItemStock/compare)

## ファイル構造

### /Data

`StorageHelper.swift` codes that operates Core Data database. このファイルには、Core Data データベースを運用するコードが含まれています。

`MetaDataHelper.swift` codes that helps to fetch the icon and title of a given URL. URLのアイコンとタイトルを取得するためのコード

`Stock.xcdatamodeld` Core Data database model file. データベースモデルファイル

### /Views

This folder contains all the SwiftUI views.

`ContentView.swift`: the view that shows when you click on the menu bar icon. It allows you to view all stocked items, search, or perform actions. メニューバーアイコンをクリックして表示されるもので、ストックされている全てのアイテムを表示したり、検索したり、アクションを実行することができます。

`ItemViewCard.swift`: The individual cell of the table view that shows one item. アイテムを表示するテーブルビューの各セル

`TagView.swift` is the view that shows a blue tag タグ; `SearchTextFieldView.swift` is a search box view サーチボックスビュー.

## License

このリポジトリは、GPL-3.0 Licenseを使用して認可されています。このコードは、個人的利用を目的としたものですので、このコード（またはこのコードの改変版）をApp Storeに公開することはできません。

This repository is licensed using GPL-3.0 License. You cannot publish this code (or a modified version of this code) to the App Store. This code is for personal usage.

