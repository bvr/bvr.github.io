---
layout: post
title: My indent style for perl
category: perl
perex: >
  You can see my indentation style in articles around, but here is a way I am
  using to automate this layout. It is handy when I get some messy code and 
  also practical to reformat some parts of my code.
tags:
  - perl
  - indent
  - perltidy
  - style
---

## SciTE

I have setup an action in my primary editor [SciTE][scite] to reformat selected
portion of text:

    command.name.4.$(file.patterns.perl)=Perl Tidy
    command.4.$(file.patterns.perl)=perltidy.cmd -pro=$(SciteDefaultHome)/.perltidyrc
    command.input.4.$(file.patterns.perl)=$(CurrentSelection)
    command.replace.selection.4.$(file.patterns.perl)=1
    command.is.filter.4.$(file.patterns.perl)=1
    command.mode.4.$(file.patterns.perl)=filter:yes,savebefore:yes



## Universal Indent GUI

Since [perltidy][perltidy] has plenty of options, I was looking for a tool
to fine-tune my options. The [Universal Indent GUI][uig] works quite well:

![Universal Indent GUI](/img/uig.png)


## perltidy resource file

I am using [perltidy][perltidy] configuration that originates from Mojo team 
[.perltidyrc][mojo_perltidyrc]:

    -i=4     # Indent level is 4 cols
    -ci=4    # Continuation indent is 4 cols
    -se      # Errors to STDERR
    -vt=2    # Maximal vertical tightness
    -cti=0   # No extra indentation for closing brackets
    -bt=1    # Medium brace tightness
    -sbt=1   # Medium square bracket tightness
    -bbt=1   # Medium block brace tightness
    -nsfs    # No space before semicolons
    -nolq    # Don't outdent long quoted strings
    -wbb="% + - * / x != == >= <= =~ < > | & **= += *= &= <<= &&= -= /= |= >>= ||= .= %= ^= x="
             # Break before all operators

    # extras/overrides/deviations from PBP

    --maximum-line-length=78                 # be less generous
    --warning-output                         # Show warnings
    --maximum-consecutive-blank-lines=2      # default is 1
    --nohanging-side-comments                # troublesome for commented out code

    -isbc # block comments may only be indented if they have some space characters before the #
    -ci=4 # Continuation indent is 2 cols

    # we use version control, so just rewrite the file
    -b

    # for the up-tight folk :)
    -pt=2  # High parenthesis tightness
    -bt=2  # High brace tightness
    -sbt=2 # High square bracket tightness


[uig]:             http://universalindent.sourceforge.net/
[perltidy]:        http://perltidy.sourceforge.net/
[mojo_perltidyrc]: http://github.com/kraih/mojo/blob/685a370c882b1e7f22fde88f00eb222c14cbb2c2/.perltidyrc
