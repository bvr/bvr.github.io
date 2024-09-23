---
layout: post
title: Iterator slice
published: yes
tags:
  - perl
  - Path::Class::Rule
  - List::Util
  - Iterator::Simple
  - natatime
  - ihead
  - list
  - block_ok
---
In a [previous post]({% post_url 2024-05-12-list-allutils %}), I discussed using the `natatime` function from the [List::Util][2] module to process a list in blocks of a defined size. This method works well, but I often need the same functionality for an iterator, which provides one item per call. For example

```perl
use Path::Class::Rule;

my $finder = Path::Class::Rule->new->file->iname("*.md");
my $files = $finder->iter("..\\_posts");
while(my $file = $files->()) {
    # do something with $file
}
```

This code recursively traverses the `..\_posts` directory and yield an object for each `.md` file. But what if I want to process these files in blocks of 10? Let's explore some options.


## A Custom `block_of` Function

At first, I wrote a simple function to gather items into blocks:

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

We can use this function like so:

```perl
# get the iterator as before ...
my $files = ...
while(my @files = block_of($files, 10)) {
    # process the @files
}
```

This approach works well, but I thought about how to simplify it further.

## Using [Iterator::Simple][1]

The [Iterator::Simple][1] module offers a more concise way to handle this. The `ihead` function returns an iterator that yields a specified number of items. Additionally, the `list` function collects everything from an iterator into a list reference. Combined, these functions provide a neat solution:

```perl
use Iterator::Simple qw(ihead list);

# get the iterator as before ...
my $files = ...
while(my @files = @{ list ihead(10, $files) }) {
    # process the @files
}
```

I used this approach to process Matlab models in batches, and it works smoothly. When the `$files` iterator is exhausted, the returned list is empty, and the loop terminates naturally.

[1]: https://metacpan.org/pod/Iterator::Simple
[2]: https://metacpan.org/pod/List::Util