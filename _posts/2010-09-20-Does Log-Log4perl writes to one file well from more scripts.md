---
layout: post
title: Does Log::Log4perl writes into files well
category:
    - perl
    - Log::Log4perl
---

Simple test (log_test.pl):

<!-- more -->

{% highlight perl %}
use Log::Log4perl qw(:easy);

Log::Log4perl->easy_init({
    level => $DEBUG,
    file  => ">>test.log",
});

my $id = shift;

for (1..20) {
    DEBUG "tick $_ from $id";
    sleep(1);
}
{% endhighlight %}

Runned simultaneously several times:

    perl -E "say for 1..10" | xargs -n 1 -P 10 perl log_test.pl

Created test.log contains entries like this

    2010/09/20 10:41:59 tick 1 from 4
    2010/09/20 10:41:59 tick 1 from 9
    2010/09/20 10:41:59 tick 1 from 1
    ....

We should have ticks 1..20 from 10 processes. Do we?

    perl -nE "$arr[$1][$2]=1 if /tick (\d+) from (\d+)/; END{ for $t(1..20){ for $f (1..10){ say qq{miss tick $t from $f} if !$arr[$t][$f] }} }" test.log

Yields

    miss tick 2 from 10
    miss tick 3 from 9
    miss tick 5 from 4
    miss tick 7 from 4
    miss tick 10 from 9
    miss tick 11 from 7
    miss tick 13 from 4
    miss tick 15 from 2
    miss tick 15 from 9
    miss tick 17 from 4
    miss tick 17 from 10
    miss tick 19 from 9

Apparently not.

I did not stop here, playing with various configuration and found working
method:

{% highlight perl %}
use Log::Log4perl qw(:easy);

Log::Log4perl->init(\ qq{
    log4perl.logger               = DEBUG, A1
    log4perl.appender.A1          = Log::Dispatch::File::Locked
    log4perl.appender.A1.filename = test5.log
    log4perl.appender.A1.mode     = append
    log4perl.appender.A1.close_after_write = 1
    log4perl.appender.A1.layout   = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.A1.layout.ConversionPattern = %d{yyyy/MM/dd hh:mm:ss} %m%n
});

my $id = shift;

for (1..20) {
    DEBUG "tick $_ from $id";
    sleep(1);
}
{% endhighlight %}

Seems like Log::Dispatch::File::Locked is working fine here. Note that
without close_after_write enable this is really slow and the ten processes
take much more time to finish.
