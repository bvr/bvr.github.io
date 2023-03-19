---
layout: post
title: Iterator::Simple
published: yes
tags:
  - perl
  - Iterator::Simple
---
Since I read the [Higher-Order Perl][1] by Mark Jason Dominus I became big fan of iterator approach. As shown in few previous posts like [Date range]({% post_url 2023-01-17-date-range %}) or [BST Successor Search]({% post_url 2022-12-05-bst-successor-search %}), I am usually using [Iterator::Simple][2] to build iterators.

The iterator itself is just anonymous function that returns next item, until it returns `undef` when iteration is exhausted. There are many ways to build an iterator, but probably simplest is to write such function directly. Here is an example to build a range of numbers

```perl
use Iterator::Simple qw(iterator);

sub range {
    my ($from, $to, $step) = @_;
    $step //= 1;

    my $i = $from - $step;
    iterator {
        $i += $step;
        return if $i > $to;
        return $i;
    }
}
```

Usage of such iterator is easy, just create an instance using `range` function and iterate using `next` method it provides

```perl
my $up_to_ten = range(1,10);
while(defined(my $n = $up_to_ten->next)) {
    say $n;
}
```

Other means to create an iterator is via `iter` function. You can check with `is_iterable` whether it can create iterator from what was specified. It supports file handles, array references, objects with `next` method or `__iter__` method. For example, here are iterators from opened file handle and testing iterator from array reference

```perl
use Iterator::Simple qw(iter);
use Path::Class qw(file);

my $input_file = shift;
my $lines = iter(file($input_file)->openr);     # iterator from opened file handle
my $test = iter([                               # iterator from array reference
    '$ cd /',
    '$ ls',
    'dir a',
    '14848514 b.txt',
    '8504156 c.dat',
]);
```

Since the iterator is reference to anonymous function, it is very cheap to pass it around as a parameter into a function. The `Iterator::Simple` module also provides number of helpers that can work with them.

 - `imap` - transformation for each item

```perl
my $passphrases = imap { chomp; $_ } iter(\*DATA);  
```

 - `igrep` - select items that match a condition

```perl
my $filtered = igrep { $_ % 4 == 0 } $it;
```

 - `ichain` - chains multiple iterators into one
 - `ienumerate` - creates iterator that produces array reference pairs of index and the item
 - `izip` - puts together first items from all iterators, then second items, etc
 - `islice`, `ihead`, `iskip` - allows to skip/get specified number of items
 - `list` - turns iterator into array reference. Obviously works only for finite iterators

Last example comes from [Dueling Generators][3] of 2017 Advent Of Code. The `generator` function creates infinite iterator of the values and `matches` function implements the "judge" to count matching pairs. Note how easy it was for second part to add filtering of values via `igrep` and rest of the program stayed the same.

```perl
use Function::Parameters;
use Iterator::Simple qw(iterator ihead list izip imap igrep);
use Data::Dump;

use Test::More;

# part 1
{
    my $a = generator(init => 699, factor => 16807);
    my $b = generator(init => 124, factor => 48271);
    is matches(a => $a, b => $b, samples => 40_000_000), 600, 'Input for part 1 matches';
}

# part 2
{
    my $a = igrep { $_ % 4 == 0 } generator(init => 699, factor => 16807);
    my $b = igrep { $_ % 8 == 0 } generator(init => 124, factor => 48271);
    is matches(a => $a, b => $b, samples => 5_000_000), 313, 'Input for part 2 matches';
}

done_testing;


fun matches(:$a, :$b, :$samples) {
    my $judge = imap { ($_->[0]&0xFFFF) == ($_->[1]&0xFFFF) ? 'x' : '-' } izip $a, $b;
    my $matches_in_first_few = igrep { $_ eq 'x' } ihead($samples, $judge);
    my $count = 0;
    $count++ while $matches_in_first_few->next;
    return $count;
}

fun generator(:$init, :$factor) {
    my $prev = $init;
    return iterator {
        $prev = ($prev * $factor) % 2147483647;
        return $prev;
    }
}
```

[1]: https://hop.perl.plover.com/book/
[2]: https://metacpan.org/pod/Iterator::Simple
[3]: http://adventofcode.com/2017/day/15
