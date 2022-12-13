---
layout: post
title: Repeated match with regex
tags:
    - perl
    - regex
    - capture
---
I wrote parsing for [graphviz][1] dot files 
today and found interesting feature of perl regex engine. It can match a 
pattern repeatedly to sections of the string. 

Small excerpt looks like this.

```perl
my $dot_props = 'len=2,font="Arial Black",style=box';
while($dot_props =~ /\G \s* (\w+) \s* = \s* (\w+|".*?") \s* ,? /gcx) {
    print "$1\t$2\n";
}
```

The string for parsing is defined on first line, there are several key-value
pairs separated by comma. Simple <b>split</b> on comma does not work well here,
because it can also show up between quotes.

Pieces
------

One pair can be matched by this regex

```perl
/ \s* (\w+) \s* = \s* (\w+|".*?") /x;
```

For those unfamiliar with the syntax:

|Code|Description|
|---|---|
|`\s*`|any number of whitespace including none|
|`(\w+)`|captured group of word (alphanumeric) characters|
|`=`|normal character match|
|`(\w+|".*?")`|captured group of either word or anything in quotes|

Now using global match in a loop we can get one pair after another. The only
remaining part is taking in account last comma (optional) and anchor regex to
end of previous match with `\G`.

Conclusion
----------

So the example on the top produces this output

```perl
len     2
font    "Arial Black"
style   box
```

[1]: http://www.graphviz.org
