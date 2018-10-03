---
title: none
---

<div class="jumbotron">
  <h1>LuaWebDriver</h1>
  <p>{{ site.description.ja }}</p>
  <p>最新版
     (<a href="news/#version-{{ site.version | replace:".", "-" }}">{{ site.version }}</a>)
     は{{ site.release_date }}にリリースされました。
  </p>
  <p>
    <a href="tutorial/"
       class="btn btn-primary btn-lg"
       role="button">チュートリアルをやってみる</a>
    <a href="install/"
       class="btn btn-primary btn-lg"
       role="button">インストール</a>
  </p>
</div>

## LuaWebDriverについて {#about}

LuaWebDriverは[WebDriver][webdriver]APIを使ったブラウザー自動操作ライブラリーです。

## ドキュメント {#documentations}

  * [お知らせ][news]: リリース情報。

  * [インストール][install]: LuaWebDriverのインストール方法

  * [チュートリアル][tutorial]: LuaWebDriverの使い方を1つずつ説明。

  * [リファレンス][reference]: クラスやメソッドなど個別の機能の詳細な説明。

## ライセンス {#license}

LuaWebDriverは[MITライセンス][mit-license]です。

著作権保持者など詳細は[LICENSE][license]ファイルを見てください。

[webdriver]:https://www.w3.org/TR/webdriver1/

[news]:news/

[install]:install/

[tutorial]:tutorial/

[reference]:reference/

[mit-license]:https://opensource.org/licenses/mit

[license]:https://gitlab.com/clear-code/lua-web-driver/blob/master/LICENSE
