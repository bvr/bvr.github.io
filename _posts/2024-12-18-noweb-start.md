---
layout: post
title: Disable web in Start menu
published: yes
tags:
  - windows
  - startup
  - registry
  - start menu
  - bing
---
My usual usage of Windows Start menu is to click the `Win` button and type a name of a program, document, or a setting name. I don't even remember when I tried to scroll around for last time. One quite annoying feature is however trying to include results of Bing search into the result. When I want to do anything with internet, I always go to the browser.

When it hit me last time, I went to the internet if it could be disabled somehow. And surely enough, one of the first hits was [How to Disable Windows Web Search and Speed Up Your PC][1].

Long story short, in the registry `HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer` create DWORD `DisableSearchBoxSuggestions` and set it to value 1. After the reboot, it works much better for me.

[1]: https://www.tomshardware.com/how-to/disable-windows-web-search
