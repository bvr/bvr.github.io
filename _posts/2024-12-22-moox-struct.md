---
layout: post
title: MooX::Struct
published: yes
tags:
  - perl
  - OOP
  - class
  - Moo
  - MooX::Struct
  - Function::Parameters
  - MooX::StrictConstructor
  - namespace::clean
  - Type::Tiny
  - Types::Standard
---
When I need a class in perl, I usually reach for [Moo][1] and several other companion classes. My usual boilerplate is something like this:

```perl
package Direction;
use Moo;
use Types::Standard qw(Int);
use Function::Parameters;
use namespace::clean;
use MooX::StrictConstructor;

has dx => (is => 'ro', isa => Int, required => 1);
has dy => (is => 'ro', isa => Int, required => 1);

method up($class:) {
    return Direction->new(dx => 0, dy => -1);
}

method clockwise() {
    # 90° clockwise rotation: (x,y) becomes (y,−x) 
    return Direction->new(dx => -$self->dy, dy => $self->dx);
}

method opposite() {
    return Direction->new(dx => -$self->dx, dy => -$self->dy);
}

method to_string() {
    return join ',', $self->dx, $self->dy;
}

1;
```

Few notes and rationale for above:

 - I started making classes with [Moose][2], but later found I don't need the meta-protocol very often and `Moo` is usually more than enough for my needs
 - [Type::Tiny][3] and [Types::Standard][4] are wonderful for type constraints, even pretty complicated ones like `HashRef[ArrayRef[InstanceOf['Point']]]`
 - [Function::Parameters][5] provide nice and fast (see [my benchmark]({% post_url 2010-12-01-method-benchmark %})) implementation for parameters, unpacking `$self`, or building class methods
 - [namespace::clean][6] removes imported functions from the class interface. This means `has`, type constraints, or anything used internally
 - [MooX::StrictConstructor][7] prevents typos in constructor usage and make sure only supported properties are supplied. Unfortunately it needs to be specified *after* the `namespace::clean`, because of [this problem][8]
 - Also note the factory method `up` to build the object some custom way. I often have something like `from_string` or `from_xml` to build the class

Now this provides many nice features and good way to grow, but feels a bit over when you just need small storage class. Here the [MooX::Struct][9] can be of use:

```perl
use MooX::Struct
    Empty => ['length'],
    Data  => ['id', 'length'],
    Block => ['id', 'pos'],
;

my @array = (
    Empty->new(length => 5),
    Data->new(length => 5, id => 125),
    Data->new(length => 8, id => 129),
    Empty->new(length => 3),
    Data->new(length => 8, id => 172),
);
```

It creates three small `Moo`-based classes with read-only attributes defined as specified. This is really basic usage, there are plenty of options how to override this behavior, inherit other structs, use roles, add methods and such. But in larger usage the boilerplate is not that big deal, so I usually only use it for small things.

[1]: https://metacpan.org/pod/Moo
[2]: https://metacpan.org/pod/Moose
[3]: https://metacpan.org/pod/Type::Tiny
[4]: https://metacpan.org/pod/Types::Standard
[5]: https://metacpan.org/pod/Function::Parameters
[6]: https://metacpan.org/pod/namespace::clean
[7]: https://metacpan.org/pod/MooX::StrictConstructor
[8]: https://metacpan.org/pod/MooX::StrictConstructor#Interactions-with-namespace::clean
[9]: https://metacpan.org/pod/MooX::Struct
