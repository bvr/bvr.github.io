---
layout: post
title: My Firefox setup
published: yes
tags:
  - Mozilla
  - Firefox
  - Configuration
  - JIRA
  - Extension
  - Tree Style Tab
  - Copy PlainText
  - Duplicate Tabs Closer
  - Cookies
  - uBlock Origin
---
I mentioned in some [previous posts]({% post_url 2023-03-05-firefox %}) that my primary browser is [Mozilla Firefox][1]. I use it on all my Windows computers and also on my Android phone. It keeps everything synchronized, so you can easily continue where you ended on the other machine.

I will talk about extensions later, but one of most important is [Tree Style Tab][2] that allows to organize open pages in a collapsible tree. When you work with many sources on multiple projects, this is great way to keep on top of it. My browser look like this:

![Firefox](/img/firefox.png)

One downside is that the original tabs are still visible when you install the extension. Following steps can hide it:

 - Go to `about:config` in the browser, set `toolkit.legacyUserProfileCustomizations.stylesheets` to `True`
 - Go to `about:support`, under `Profile Folder` select `Open Folder`
 - In the folder, create `chrome` directory, create file `userChrome.css` with following contents:

```css
/* hides the native tabs */
#TabsToolbar {
  visibility: collapse;
}
#main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
  opacity: 0;
  pointer-events: none;
}
#main-window:not([tabsintitlebar="true"]) #TabsToolbar {
    visibility: collapse !important;
}
#sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
  display: none;
}
.tab {
  margin-left: 1px;
  margin-right: 1px;
}
```

## Other Extensions I use

 - [Copy PlainText][3] - provides a function to copy text as is without any formatting
 - [Duplicate Tabs Closer][4] - I mostly use this to remove my [JIRA](https://www.atlassian.com/software/jira) tickets. I usually get them through communicators or emails as well as email notifications. It is very common that same ticket gets opened multiple times
 - [I still don't care about cookies][5] - accept cookies without having to click
 - [uBlock Origin][6] - block Ads and other annoying parts in pages

[1]: https://www.mozilla.org/en-US/firefox/new/
[2]: http://piro.sakura.ne.jp/xul/_treestyletab.html.en
[3]: https://addons.mozilla.org/en-US/firefox/addon/copy-plaintext/
[4]: https://addons.mozilla.org/en-US/firefox/addon/duplicate-tabs-closer/
[5]: https://addons.mozilla.org/en-US/firefox/addon/istilldontcareaboutcookies/
[6]: https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/
