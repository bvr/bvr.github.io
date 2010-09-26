---
layout: post
title: Repeated match with regex
category:
    - perl
    - regex
---

The regex used actually start at the end of previous match.

{% highlight perl %}
while($name =~ /\G ( FCE\d+ | FCE_\w{3}_\d+ | SRDD_\w{3}_\d+ ) _? /gcx) {
    my $anchor_elem = $db->elem_by_id($1);
    $anchor_elem && $anchor_elem->set_circled($file);
}
{% endhighlight %}
