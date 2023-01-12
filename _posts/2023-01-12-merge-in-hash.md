---
layout: post
title: Merge data into a hash
published: yes
tags:
  - perl
  - hash
  - merge
---
Perl hash (often called dict/dictionary in other languages) is very useful structure to store key-value associations in one compact structure.

For example

```perl
my $person = {
    name    => 'Joe',
    surname => 'Smith',
    address => '123 Elm street',
    city    => 'Boston',
};
```

A hash reference (basically a scalar with an address) is used here, so the initialization is with `{}`. I needed code to update such hash with data from another one, which was created by an user action, something like this

```perl
my $updated = {
    name    => 'Jim',
    city    => 'Denver',
    zip     => '80014',
};
```

The code I came with is based on the fact that `keys` and `values` functions return items in same order as is internally stored in the hash, so simple slice assignment would do

```perl
@{ $person }{ keys %$updated } = values %$updated;
```

When dumped with

```perl
use Data::Dump;
dd $person;
```

we got updated `name` and `city` and added `zip` entry

```
{
  address => "123 Elm street",
  city => "Denver",
  name => "Jim",
  surname => "Smith",
  zip => 80014,
}
```
