---
layout: post
title: Topological sort
published: yes
tags:
  - perl
  - topological sort
  - algorithm
---
I run across very useful algorithms for situation where total order of a sequence is not clear
in [excellent article of Eric Lippert](https://blogs.msdn.microsoft.com/ericlippert/2004/03/16/im-putting-on-my-top-hat-tying-up-my-white-tie-brushing-out-my-tails-in-that-order/). It allows you to make sure some items go earlier than others, typically when we have some dependencies. I recently used it for sequential processing of interdependent sets of safety cutsets.

In referenced article it is implemented in javascript, I basically rewrote it into perl:

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
