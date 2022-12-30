---
layout: post
title: Topological sort
published: yes
tags:
  - perl
  - topological sort
  - algorithm
---
I run across very useful algorithms for situation where total order of a sequence is not clear in [excellent article of Eric Lippert][1]. It allows you to make sure some items go earlier than others, typically when we have some dependencies. I recently used it for sequential processing of interdependent sets of safety [cutsets][2].

In referenced article it is implemented in javascript, I basically rewrote it into perl, so I can play with it.

```perl
use Data::Dump;

my $deps = {
    tophat      => [],
    bowtie      => ["shirt"],
    socks       => [],
    pocketwatch => ["vest"],
    vest        => ["shirt"],
    shirt       => [],
    shoes       => ["trousers", "socks"],
    cufflinks   => ["shirt"],
    gloves      => [],
    tailcoat    => ["vest"],
    underpants  => [],
    trousers    => ["underpants"],
};

dd toposort($deps);     # ["shirt", "vest", "tailcoat", "gloves", "socks", "tophat", "underpants", "trousers", "bowtie", "pocketwatch", "shoes", "cufflinks"]

# partially sort the items so dependencies are respected
sub toposort {
    my ($dependencies) = @_;

    my $dead = {};
    my $list = [];

    for my $dependency (keys %$dependencies) {
        $dead->{$dependency} = 0;
    }

    for my $dependency (keys %$dependencies) {
        visit($dependencies, $dependency, $list, $dead);
    }
    return $list;
}

sub visit {
    my ($dependencies, $dependency, $list, $dead) = @_;

    return if $dead->{$dependency};

    $dead->{$dependency} = 1;
    for my $child (@{ $dependencies->{$dependency} }) {
        visit($dependencies, $child, $list, $dead);
    }

    push @$list, $dependency;
}
```


[1]: https://blogs.msdn.microsoft.com/ericlippert/2004/03/16/im-putting-on-my-top-hat-tying-up-my-white-tie-brushing-out-my-tails-in-that-order/
[2]: https://en.wikipedia.org/wiki/Cut_(graph_theory)
[3]: https://rosettacode.org/wiki/Topological_sort#C.23
