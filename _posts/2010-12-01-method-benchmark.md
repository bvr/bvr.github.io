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
  - Function::Parameters
---
**Update 2024-11-25:** Added [Function::Parameters][fp] into the benchmark.

Here is benchmark of running methods of perl class defined by several methods: 

 - plain perl sub
 - [Method::Signatures::Simple][mss] 
 - [MooseX::Declare][mxd]
 - [Function::Parameters][fp]

### Introduction

There are ways how to avoid typing when defining a perl classes. While modules like [Moose][moose] or [Class::Accessor][ca] typically take care of attribute accessor generation while methods are usually left as they are in plain perl. Usual pattern looks like this:

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

but I quickly realized that it is slow. Very slow. So I reverted it back to plain perl by a small script and stopped thinking about methods and their signatures.

But recently I found another module trying to achieve same syntax, [Method::Signatures::Simple][mss] (MSS). Still remembering previous lesson, made some benchmarks to prevent surprises later. Further work led me to use of [Function::Parameters][fp], which has even nicer syntax.

### Results

[Benchmark][benchmark] module brings handy `cmpthese` function, that runs the variants and 
creates handy comparison table:

                Rate    mxd  plain    mss     fp
    mxd      46367/s     --  -100%  -100%  -100%
    plain 11851048/s 25459%     --    -9%   -18%
    mss   13025677/s 27992%    10%     --   -10%
    fp    14485495/s 31141%    22%    11%     --

It looks that MSS bring very minor penalty, while slowness of MXD is more than apparent. What was pretty surprising, [Function::Parameters][fp] that use keyword filter built in more recent perls is even faster than plain method.

### Benchmark source

```perl
use Benchmark qw(:all);

my $plain = Plain->new();
my $mss   = MSS->new();
my $mxd   = MXD->new();
my $fp    = FP->new();

cmpthese(-2, {
    plain => sub { $plain->run(10,20) },
    mss   => sub { $mss->run(10,20)   },
    mxd   => sub { $mxd->run(10,20)   },
    fp    => sub { $fp->run(10,20)    },
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


    package FP;
    use Function::Parameters;
    sub new { bless {},shift }
    method run($a,$b) {
        my ($c,$d) = ($a,$b);
    }
}
```

[moose]: https://metacpan.org/pod/Moose
[mss]:   https://metacpan.org/pod/Method::Signatures::Simple
[mxd]:   https://metacpan.org/pod/MooseX::Declare
[ca]:    https://metacpan.org/pod/Class::Accessor
[fp]:    https://metacpan.org/pod/Function::Parameters
[benchmark]: https://metacpan.org/pod/Benchmark
