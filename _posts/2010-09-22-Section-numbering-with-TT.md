---
layout: post
title: Section numbering with Template Toolkit
tags:
    - perl
    - template
    - Template Toolkit
    - tpage
---
Recently I was working on documentation for web-based intranet application. Every
page is created from templates processed by [Template Toolkit][1].
So why not move heading definition into separate block and generate TOC automatically.

Below is the approach demonstrated, just on simple text file.

The template
------------

    [% toc = []; toc_number = [ 0, 0 ] ~%]
    [% BLOCK head %]
    [%- SWITCH level %]
    [%- CASE 1 %][% underline = '='; toc_number.0 = toc_number.0 + 1; toc_number.1 = 0 %]
    [%- CASE 2 %][% underline = '-'; toc_number.1 = toc_number.1 + 1 %]
    [%- END ~%]

    [% title = toc_number.first(level).join(".") _ "  " _ title; title %]
    [% underline.repeat(title.length + 1) %]

    [%~ toc.push({ 'level' => level, 'title' => title }) ~%]
    [% END ~%]

    [%~ text = BLOCK %]
    [% PROCESS head title='Introduction' level=1 %]

    This is overall introduction into the problem.

    [% PROCESS head title='Scope'        level=2 %]

    These instructions pertain specifically to some scope that should be covered here.

    [% PROCESS head title='Copyright'    level=2 %]

    Any copyright clausule ...

    [% PROCESS head title='Overview'     level=1 %]

    Quick summary and high level overview of the problem.

    [% END ~%]

    CONTENTS

    [% indent = "   " ~%]
    [% FOREACH toc_entry IN toc %]
    [%~ indent.repeat(toc_entry.level - 1) %][% toc_entry.title %]
    [% END %]
    [% text %]

Process the template
--------------------

Convert to output with *tpage* tool (included in Template Toolkit):
```bash
tpage text_with_contents.txt
```

Ouput
-----

    CONTENTS

    1  Introduction
       1.1  Scope
       1.2  Copyright
    2  Overview


    1  Introduction
    ================

    This is overall introduction into the problem.

    1.1  Scope
    -----------

    These instructions pertain specifically to some scope that should be covered here.

    1.2  Copyright
    ---------------

    Any copyright clausule ...

    2  Overview
    ============

    Quick summary and high level overview of the problem.

[1]: http://template-toolkit.org/
