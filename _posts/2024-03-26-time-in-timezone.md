---
layout: post
title: Show time in a specific timezone
published: yes
tags:
  - perl
  - date
  - time
  - time zone
  - DateTime
  - DateTime::TimeZone
  - Path::Class
---
At work we have a system that has regularly generated data and I need to display a timestamp when it was last updated. Up until now I used just date, but users requested better granularity. This present a problem, since our company is working from multiple places around the world, so with time there should come information about the time zone.

So I needed to determine local time zone, get the file modification time and put them together to display human-readable entry. With help of [DateTime][1] and [Path::Class][2] modules, it was quite easy:

```perl
use DateTime;
use Path::Class qw(file);

my $local_tz = DateTime::TimeZone->new(name => 'local');

my $mtime = file('data.txt')->stat->mtime;
my $map_mtime = DateTime->from_epoch(epoch => $mtime, time_zone => $local_tz);
print $map_mtime->format_cldr('yyyy-MM-dd hh:mm zzz');
```

When run, it provides following output:

```
2024-03-13 04:10 CET
```

[1]: https://metacpan.org/pod/DateTime
[2]: https://metacpan.org/pod/Path::Class
