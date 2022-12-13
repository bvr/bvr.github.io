---
layout: post
title: Log::Log4perl in multiple processes
tags:
    - perl
    - Log::Log4perl
    - Log::Dispatch::File::Locked
---
I am using [Log::Log4perl][1] to produce logs from my perl fastcgi applications.
There is typically several same processes writing into same log. I was wondering
if it is possible to lose some messages this way.

So I made a simple test - the code went into `log_test.pl`.

```perl
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
```

Then run simultaneously several times:

```bash
perl -E "say for 1..10" | xargs -n 1 -P 10 perl log_test.pl
```

That created `test.log` file with entries like

    2010/09/20 10:41:59 tick 1 from 4
    2010/09/20 10:41:59 tick 1 from 9
    2010/09/20 10:41:59 tick 1 from 1
    ....

Now, we should have ticks 1..20 from 10 processes. Do we?

```perl
open(my $I,"test.log");
while(<$I>) {
    $arr[$1][$2] = 1 if /tick (\d+) from (\d+)/;
}

for my $t (1..20) {
    for my $f (1..10) {
        print "missing tick $t from $f\n" if !$arr[$t][$f];
    }
}
```

Yields

    missing tick 2 from 10
    missing tick 3 from 9
    missing tick 5 from 4
    missing tick 7 from 4
    missing tick 10 from 9
    missing tick 11 from 7
    missing tick 13 from 4
    missing tick 15 from 2
    missing tick 15 from 9
    missing tick 17 from 4
    missing tick 17 from 10
    missing tick 19 from 9

Apparently not.

I did not stop here and after few hours playing with various configuration
found working method:

```perl
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
```

Seems like [Log::Dispatch::File::Locked][2] is working fine here. Note that
without `close_after_write` enable this is really slow and the ten processes
take much more time to finish.

[1]: https://metacpan.org/pod/Log::Log4perl
[2]: https://metacpan.org/pod/Log::Dispatch::File::Locked
