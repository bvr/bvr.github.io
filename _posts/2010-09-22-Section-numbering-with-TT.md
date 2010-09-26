---
layout: post
title: Section numbering with Template Toolkit
category:
    - perl
    - Template
    - tpage
---

TODO: remove any reference to Honeywell stuff


Template contents:

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

    GTT tracing tool was developed for general traceability verification/auditing.

    [% PROCESS head title='Scope'        level=2 %]

    These instructions pertain specifically to GTT tool used for the Boeing 787
    Program.

    [% PROCESS head title='Copyright'    level=2 %]

    [% PROCESS copyright %]

    [% PROCESS head title='Overview'     level=1 %]

    According to waterfall model of development, there are documentation on several
    levels:

     - customer specified requirements in form of SCD document
     - program requirements in SRS documents based on customer requirements
     - design documents (SRDD) that describes both high-level and low-level design
     - hardware documents (HRD)
     - source code (SRC) and models (SRDDML)
     - test procedures (TPP and TVO)

    [% END ~%]

    CONTENTS

    [% indent = "   " ~%]
    [% FOREACH toc_entry IN toc %]
    [%~ indent.repeat(toc_entry.level - 1) %][% toc_entry.title %]
    [% END %]
    [% text %]

Commandline:

    tpage text_with_contents.txt

Yields:

    CONTENTS

    1  Introduction
       1.1  Scope
       1.2  Copyright
    2  Overview


    1  Introduction
    ================

    GTT tracing tool was developed for general traceability verification/auditing.

    1.1  Scope
    -----------

    These instructions pertain specifically to GTT tool used for the Boeing 787
    Program.

    1.2  Copyright
    ---------------

    (c) Honeywell International Inc. This software and all information and
    expression are the property of Honeywell International Inc., contain trade
    secrets and may not, in whole or in part, be licensed, used, duplicated, or
    disclosed for any purpose without prior written permission of Honeywell
    International Inc. All Rights Reserved


    2  Overview
    ============

    According to waterfall model of development, there are documentation on several
    levels:

     - customer specified requirements in form of SCD document
     - program requirements in SRS documents based on customer requirements
     - design documents (SRDD) that describes both high-level and low-level design
     - hardware documents (HRD)
     - source code (SRC) and models (SRDDML)
     - test procedures (TPP and TVO)
