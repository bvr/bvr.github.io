---
layout: post
title: List::AllUtils
published: yes
tags:
  - perl
  - algorithm
  - List::AllUtils
  - minmax
  - pairkeys
  - pairvalues
  - natatime
  - partition_by
---
The functional approach to programming leads to extensive list processing. In perl, there are several modules that offer all kinds of utilities to do that efficiently, like [List::Util][1] or [List::MoreUtils][2]. Since I started using them, I wished there was one solution that includes all of them, so I don't have to always look where it is. Probably out of the same sentiment the [List::AllUtils][3] was created.

It is well worth reading the documentation to at least have an idea of what is available. Here are my favorites.

### Aggregators

On top of usual `sum`, `min` and `max`, sometimes it is handy to find range of the data with `minmax`

```perl
use List::AllUtils qw(minmax);
my ($min, $max) = minmax(@data);
```

### Junctions

While a lot of work is possible with standard `grep` function, it is more readable to write stuff like

```perl
if(all { $_->writable } @files) {
    # do the work
}
```

### Pairs

Works with list of pairs. This is very useful to have something similar to a hash, but with retained order. For instance we might want to keep the table headers and data processing together like in [this post]({% post_url 2023-01-10-table-generation %})

```perl
use List::AllUtils qw(pairkeys pairvalues);
use Function::Parameters;

my @table = (
    "First Name" => fun($row) { $row->first_name },
    "Last Name"  => fun($row) { $row->last_name },
    "Address"    => fun($row) { $row->address },
    "City"       => fun($row) { $row->city },
);
print join(",", pairkeys @table), "\n";
for my $row (@data_rows) {
    print join(",", map { $_->($row) } pairvalues @table), "\n";
}
```

### Groups of n items

What I use quite often is `natatime`. It builds an iterator for number of elements. It comes handy for any kind of block processing

```perl
use List::AllUtils qw(natatime);

my $iter = natatime 512, @files;
while(my @block = $iter->()) {
    # process the block
}
```

### Partitioning

Another very useful thing is `partition_by` to group items by a property

```perl
use List::AllUtils qw(partition_by);

my %signals_by_rate = partition_by { $_->rate } @signals;
```

[1]: https://metacpan.org/pod/List::Util
[2]: https://metacpan.org/pod/List::MoreUtils
[3]: https://metacpan.org/pod/List::AllUtils
