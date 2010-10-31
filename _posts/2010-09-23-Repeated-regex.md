---
layout: post
title: Repeated match with regex
category:
    - perl
    - regex
---

I wrote parsing for [graphviz](http://www.graphviz.org) dot files today and found
interesting feature of perl regex engine. It can match a pattern repeatedly
to sections of the string.

Small excerpt looks like this.

{% highlight perl %}
my $dot_props = 'len=2,font="Arial Black",style=box';
while($dot_props =~ /\G \s* (\w+) \s* = \s* (\w+|".*?") \s* ,? /gcx) {
    print "$1\t$2\n";
}
{% endhighlight %}

The string for parsing is defined on first line, there are several key-value
pairs separated by comma. Simple <b>split</b> on comma does not work well here,
because it can also show up between quotes.

Pieces
------

One pair can be matched by this regex

{% highlight perl %}
/ \s* (\w+) \s* = \s* (\w+|".*?") /x;
{% endhighlight %}

For those unfamiliar with the syntax:

<table>
<tr><td><code>\s*<td>any number of whitespace, including none
<tr><td><code>(\w+)<td>captured group of word (alphanumeric) characters
<tr><td><code>=<td>normal character match
<tr><td><code>(\w+|".*?")<td>captured group of either word or anything in quotes
</table>

Now using global match in a loop we can get one pair after another. The only
remaining part is taking in account last comma (optional) and anchor regex to
end of previous match with `\G`.

Conclusion
----------

So the example on the top produces this output

{% highlight perl %}
len     2
font    "Arial Black"
style   box
{% endhighlight %}

