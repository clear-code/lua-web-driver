---
title: none
---

<div class="jumbotron">
  <h1>LuaWebDriver</h1>
  <p>{{ site.description.en }}</p>
  <p>The latest version
     (<a href="news/#version-{{ site.version | replace:".", "-" }}">{{ site.version }}</a>)
     has been released at {{ site.release_date }}.
  </p>
  <p>
    <a href="tutorial/"
       class="btn btn-primary btn-lg"
       role="button">Try tutorial</a>
    <a href="install/"
       class="btn btn-primary btn-lg"
       role="button">Install</a>
  </p>
</div>

## About LuaWebDriver {#about}

This is a browser automation library using [WebDriver][webdriver] API. Currently, this library supports geckodriver only.

## Documentations {#documentations}

  * [News][news]: It lists release information.

  * [Install][install]: It describes how to install LuaWebDriver.

  * [Tutorial][tutorial]: It describes how to use LuaWebDriver step by step.

  * [Reference][reference]: It describes details for each features such as classes and methods.

## License {#license}

LuaWebDriver is released under [the MIT license][mit-license].

See [LICENSE][license] file for details such as copyright holders.

[webdriver]:http://xmlsoft.org/

[news]:news/

[install]:install/

[tutorial]:tutorial/

[reference]:reference/

[mit-license]:https://opensource.org/licenses/mit

[license]:https://gitlab.com/clear-code/lua-web-driver/blob/master/LICENSE
