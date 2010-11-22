---
layout: post
title: Display time from other timezone
category: perl
perex: >
  I am still working on packet analyzer 
  <a href="/2010/11/pack-hexdump/">I mentioned last time</a>. Another problem
  to solve - capture happen in different timezone and I need to output correct
  time regardless of where my script is running.
tags:
  - perl
  - localtime
  - Env::C
  - Time::Piece
  - POSIX
---
The solution is quite simple, but took me few hours to figure out. I fairly 
quickly discovered that `localtime` behavior can be changed by setting 
timezone (`TZ`) environment variable. When set from command-line, everything 
worked, but when set from inside of script 

{% highlight perl %}
$ENV{TZ} = 'GMT+7'
{% endhighlight %}

the time was for my timezone. Sometime later digging in `POSIX` library I got 
the idea that setting `TZ` in `%ENV` hash does not propagate to underlying C 
layer. Someone else has definitely similar problem, because CPAN 
module [Env::C][env_c] mention exactly that in its documentation.

This is what I end up with:

{% highlight perl %}
use POSIX qw(tzset); 
use Env::C;

Env::C::setenv('TZ','GMT+7',1);
tzset();

print scalar localtime(1289250253);  # Mon Nov  8 14:04:13 2010 everywhere
{% endhighlight %}

[env_c]: http://search.cpan.org/perldoc?Env::C
