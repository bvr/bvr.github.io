---
layout: post
title: Display time from other timezone
tags:
  - perl
  - localtime
  - Env::C
  - Time::Piece
  - POSIX
---
I am still working on packet analyzer 
[I mentioned last time][pack-hexdump]. Another problem
to solve - capture happen in different timezone and I need to output correct
time regardless of where my script is running.


The solution is quite simple, but took me few hours to figure out. I fairly 
quickly discovered that `localtime` behavior can be changed by setting 
timezone (`TZ`) environment variable. When set from command-line, everything 
worked, but when set from inside of script 

``` perl
$ENV{TZ} = 'GMT+7'
```

the time was for my timezone. Sometime later digging in `POSIX` library I got 
the idea that setting `TZ` in `%ENV` hash does not propagate to underlying C 
layer. Someone else has definitely similar problem, because CPAN 
module [Env::C][env_c] mention exactly that in its documentation.

This is what I end up with:

``` perl
use POSIX qw(tzset); 
use Env::C;

Env::C::setenv('TZ','GMT+7',1);
tzset();

print scalar localtime(1289250253);  # Mon Nov  8 14:04:13 2010 everywhere
```

[env_c]: http://search.cpan.org/perldoc?Env::C
[pack-hexdump]: {% post_url 2010-11-11-pack-hexdump %}
