---
layout: post
title: Date range
published: yes
tags:
  - perl
  - date
  - time
  - Time::Moment
  - Function::Parameters
  - Types::Standard
---
When you need to build date range with daily step between two dates, it was quite common to use a number of seconds since 1970 and keep adding number of seconds in a day. However this is rather prone to subtle or sometimes not-so-subtle problems. You can run into daylight saving time (DST) issues, leap years or leap seconds.

It is much better to use some module that will handle all those details well, not to mention much larger range for stored dates.

Here is implementation of `date_range` function with parameter checking that builds an iterator for dates along the range.

```perl
use 5.16.3;
use Time::Moment;
use Iterator::Simple qw(iterator);
use Function::Parameters;
use Types::Standard qw(InstanceOf);

my $tm1 = Time::Moment->new(year => 2012, month => 01, day => 30);
my $tm2 = Time::Moment->new(year => 2012, month => 03, day => 2);

my $it = date_range($tm1, $tm2);
while(my $point = $it->()) {
    say $point->strftime("%F");
}


fun date_range($from, $to) {
    (InstanceOf["Time::Moment"])->assert_valid($from);
    (InstanceOf["Time::Moment"])->assert_valid($to);

    my $tm = $from->plus_days(-1);
    return iterator {
        $tm = $tm->plus_days(1);
        return if $tm > $to;
        return $tm;
    }
}
```

When run, the output is reporting also leap Feb 29, that happen to occur in 2012

```
2012-01-30
2012-01-31
2012-02-01
2012-02-02
2012-02-03
2012-02-04
2012-02-05
2012-02-06
2012-02-07
2012-02-08
2012-02-09
2012-02-10
2012-02-11
2012-02-12
2012-02-13
2012-02-14
2012-02-15
2012-02-16
2012-02-17
2012-02-18
2012-02-19
2012-02-20
2012-02-21
2012-02-22
2012-02-23
2012-02-24
2012-02-25
2012-02-26
2012-02-27
2012-02-28
2012-02-29
2012-03-01
2012-03-02
```
