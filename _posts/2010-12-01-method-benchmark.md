---
layout: post
title: perl method definition benchmark
category: perl
perex: >
  Here is benchmark of running methods of perl class defined by three
  approaches: plain perl sub, with 
  <a href="http://search.cpan.org/perldoc?Method::Signatures::Simple">Method::Signatures::Simple</a>
  and with <a href="http://search.cpan.org/perldoc?MooseX::Declare">MooseX::Declare</a>.
tags:
  - perl
  - method
  - class
  - Benchmark
  - MooseX::Declare
  - Method::Signatures::Simple
---

### Introduction

There are several ways how to avoid some typing when defining perl classes. 
While modules like [Moose][moose] or [Class::Accessor][ca] typically take care 
of attribute accessor generation, methods are usually left as they are in plain 
perl. Usual pattern looks like this:

{% highlight perl %}
sub run {
    my $self = shift;
    my ($bar, $baz, %opts) = @_;
    
    ...
}
{% endhighlight %}

I used [MooseX::Declare][mxd] (MXD) in one of my recent larger projects. It looks nice

{% highlight perl %}
method run($bar, $baz, %opts) {
    ...
}
{% endhighlight %}

but I quickly realized that this is slow. Very slow. So I reverted it back to 
plain perl by small script and stopped thinking about methods and their 
signatures.

But recently I found another module trying to achieve same syntax, 
[Method::Signatures::Simple][mss] (MSS). Still remembering previous lesson, 
made some benchmarks to prevent surprises later.

### Results

Benchmark module brings handy `cmpthese` function, that runs the variants and 
creates handy comparison table:

              Rate    mxd    mss  plain
    mxd     3580/s     --   -99%   -99%
    mss   709347/s 19714%     --    -0%
    plain 709904/s 19730%     0%     --

It looks that MSS bring very minor penalty, while slowness of MXD is more than apparent.

### Benchmark source

{% highlight perl %}
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
{% endhighlight %}

[moose]: http://search.cpan.org/perldoc?Moose
[mss]:   http://search.cpan.org/perldoc?Method::Signatures::Simple
[mxd]:   http://search.cpan.org/perldoc?MooseX::Declare
[ca]:    http://search.cpan.org/perldoc?Class::Accessor
