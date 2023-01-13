---
layout: post
title: perl method definition benchmark
tags:
  - perl
  - method
  - class
  - Benchmark
  - MooseX::Declare
  - Method::Signatures::Simple
---
Here is benchmark of running methods of perl class defined by three
approaches: 

 - plain perl sub
 - [Method::Signatures::Simple][mss] 
 - [MooseX::Declare][mxd].

### Introduction

There are several ways how to avoid some typing when defining perl classes. 
While modules like [Moose][moose] or [Class::Accessor][ca] typically take care 
of attribute accessor generation while methods are usually left as they are in plain 
perl. Usual pattern looks like this:

```perl
sub run {
    my $self = shift;
    my ($bar, $baz, %opts) = @_;
    
    ...
}
```

I used [MooseX::Declare][mxd] (MXD) in one of my recent larger projects. It looks nice

```perl
method run($bar, $baz, %opts) {
    ...
}
```

but I quickly realized that it is slow. Very slow. So I reverted it back to 
plain perl by small script and stopped thinking about methods and their 
signatures.

But recently I found another module trying to achieve same syntax, 
[Method::Signatures::Simple][mss] (MSS). Still remembering previous lesson, 
made some benchmarks to prevent surprises later.

### Results

[Benchmark][benchmark] module brings handy `cmpthese` function, that runs the variants and 
creates handy comparison table:

              Rate    mxd    mss  plain
    mxd     3580/s     --   -99%   -99%
    mss   709347/s 19714%     --    -0%
    plain 709904/s 19730%     0%     --

It looks that MSS bring very minor penalty, while slowness of MXD is more than apparent.

### Benchmark source

```perl
use Benchmark qw(:all);

my $plain = Plain->new();
my $mss   = MSS->new();
my $mxd   = MXD->new();

cmpthese(-2, {
    plain => sub { $plain->run(10,20) },
    mss   => sub { $mss->run(10,20)   },
    mxd   => sub { $mxd->run(10,20)   },
});

BEGIN {
    package Plain;
    sub new { bless {},shift }
    sub run {
        my ($self,$a,$b) = @_;
        my ($c,$d) = ($a,$b);
    }


    package MSS;
    use Method::Signatures::Simple;
    sub new { bless {},shift }
    method run($a,$b) {
        my ($c,$d) = ($a,$b);
    }


    use MooseX::Declare;
    class MXD {
        method run($a,$b) {
            my ($c,$d) = ($a,$b);
        }
    }
}
```

[moose]: https://metacpan.org/pod/Moose
[mss]:   https://metacpan.org/pod/Method::Signatures::Simple
[mxd]:   https://metacpan.org/pod/MooseX::Declare
[ca]:    https://metacpan.org/pod/Class::Accessor
[benchmark]: https://metacpan.org/pod/Benchmark
