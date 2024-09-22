---
layout: post
title: Iterator slice
published: yes
tags:
  - perl
  - Path::Class::Rule
  - Iterator::Simple
  - natatime
  - ihead
  - list
  - block_ok
---
In one of [previous posts]({% post_url 2024-05-12-list-allutils %}) I mentioned the utility of `natatime` utility to process the list in blocks of defined size. This works nicely, but I often need same thing for an iterator, that is providing one item per a call. For example

```perl
use Path::Class::Rule;

my $finder = Path::Class::Rule->new->file->iname("*.md");
my $files = $finder->iter("..\\_posts");
while(my $file = $files->()) {
    # do something with $file
}
```

This common use allows us to recursively traverse the specified directory `..\_posts` and yield an entry to each `.md` file. Now if I want to process those files in blocks of 10 items, what options I have? At first, I implemented simple function to provide list of items:

```perl
sub block_of {
    my ($iterator, $block_size) = @_;

    my @block;
    while (defined(my $item = $iterator->())) {
        push @block, $item;
        return @block if @block == $block_size;
    }

    return @block;
}
```

It can be used like this:

```perl
# get the iterator as before ...
my $files = ...
while(my @files = block_of($files, 10)) {
    # process the @files
}
```

Then I thought more about it. In the [Iterator::Simple][1] there is a function `ihead` that makes an iterator that returns selected number of items. The function `list` allows to get everything from an iterator and return a reference to the list. Combined it provides following solution:

```perl
use Iterator::Simple qw(ihead list);

# get the iterator as before ...
my $files = ...
while(my @files = @{ list ihead(10, $files) }) {
    # process the @files
}
```

I used this method to process Matlab models in batches and it works quite nice. When the `$files` iterator is exhausted, the returned list is empty and the loop ends.

[1]: https://metacpan.org/pod/Iterator::Simple
