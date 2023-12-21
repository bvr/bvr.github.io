---
layout: post
title: Data::Printer
published: yes
tags:
  - perl
  - dump
  - Data::Printer
  - debugging
---
Last time we touched [Data::Dump]({% post_url 2023-12-18-data-dump %}) module for printing out data structures. Now there are situations where we don't need a perl code, but rather overview of the data printed nicely. There is a module that tries just that - [Data::Printer][1].

The module provides function `p` to pretty-print what is it supplied. Suppose we have a simple class based on [Moo][2]:

```perl
package Article {
    use Moo;
    
    has author   => (is => 'ro');
    has title    => (is => 'ro');
    has contents => (is => 'ro');
}
```

Then printing of the class might look like this:

```perl
use Data::Printer;
my $art = Article->new(
    author   => 'Roman', 
    title    => 'Data::Printer', 
    contents => 'Last time we touched ...',
);

p $art;
```

Output on terminal is like this, usually nicely colored:

```
Article  {
    Parents       Moo::Object
    public methods (4) : author, contents, new, title
    private methods (0)
    internals: {
        author     "Roman",
        contents   "Last time we touched ...",
        title      "Data::Printer"
    }
}
```

It provides many controls over the output, themes for colors, optional configuration file and much more. One thing stands out, though. In case of dumping object, often there are properties that are too internal and not interesting to see. For instance [DateTime][3] class has much state

```perl
use Data::Printer;
use DateTime;

my $now = DateTime->now;
p $now;
```

This outputs too much of information, especially when such object is used many times

```
DateTime  {
    public methods (115) : add, add_duration, am_or_pm, bootstrap, ce_year, christian_era, clone, compare, compare_ignore_floating, datetime, day_abbr, day_name, day_of_month, day_of_month_0, day_of_quarter, day_of_quarter_0, day_of_week, day_of_week_0, day_of_year, day_of_year_0, DefaultLocale, delta_days, delta_md, delta_ms, dmy, duration_class, epoch, era_abbr, era_name, format_cldr, formatter, fractional_second, from_day_of_year, from_epoch, from_object, hires_epoch, hms, hour, hour_1, hour_12, hour_12_0, INFINITY, is_dst, is_finite, is_infinite, is_last_day_of_month, is_leap_year, iso8601, jd, last_day_of_month, leap_seconds, local_day_of_week, local_rd_as_seconds, local_rd_values, locale, MAX_NANOSECONDS, mdy, microsecond, millisecond, minute, mjd, month, month_abbr, month_name, month_0, NAN, nanosecond, NEG_INFINITY, new, now, offset, quarter, quarter_abbr, quarter_name, quarter_0, second, SECONDS_PER_DAY, secular_era, set, set_day, set_formatter, set_hour, set_locale, set_minute, set_month, set_nanosecond, set_second, set_time_zone, set_year, STORABLE_freeze, STORABLE_thaw, strftime, stringify, subtract, subtract_datetime, subtract_datetime_absolute, subtract_duration, time_zone, time_zone_long_name, time_zone_short_name, today, truncate, utc_rd_as_seconds, utc_rd_values, utc_year, week, week_number, week_of_month, week_year, weekday_of_month, year, year_with_christian_era, year_with_era, year_with_secular_era, ymd
    private methods (39) : __ANON__, _accumulated_leap_seconds, _add_overload, _adjust_for_positive_difference, _calc_local_components, _calc_local_rd, _calc_utc_rd, _cldr_pattern, _compare, _compare_overload, _core_time, _day_has_leap_second, _day_length, _default_time_zone, _duration_object_from_args, _era_index, _format_nanosecs, _handle_offset_modifier, _is_leap_year, _maybe_future_dst_warning, _month_length, _new, _new_from_self, _normalize_leap_seconds, _normalize_nanoseconds, _normalize_seconds, _normalize_tai_seconds, _offset_for_local_datetime, _rd2ymd, _seconds_as_components, _set_locale, _string_compare_overload, _string_equals_overload, _string_not_equals_overload, _subtract_overload, _time_as_seconds, _weeks_in_year, _ymd2rd, _zero_padded_number
    internals: {
        formatter         undef,
        local_c           {
            day              21,
            day_of_quarter   82,
            day_of_week      4,
            day_of_year      355,
            hour             16,
            minute           56,
            month            12,
            quarter          4,
            second           52,
            year             2023
        },
        local_rd_days     738875,
        local_rd_secs     61012,
        locale            DateTime::Locale::FromData,
        offset_modifier   0,
        rd_nanosecs       0,
        tz                DateTime::TimeZone::UTC,
        utc_rd_days       738875,
        utc_rd_secs       61012,
        utc_year          2024
    }
}
```

There are two options to solve this. Either the class can implement `_data_printer` method to alter the output (I will show an example below) or we can alter the means from using filters. There are many of them already created

```perl
use DateTime;
use Data::Printer filters => ['DateTime'];
my $now = DateTime->now;
p $now;
```

Now produces nice 

```
2023-12-21T17:09:39 [UTC]
```

Last example is customizing the output from the classes itself. In one of my projects, I have hierarchy of classes that represent units - speed, distance, time, etc. It can be initialized from parsed JSON file and it inflates the value to something useful like the DateTime. Base class is setup so the Data::Printer will stringify them using its `to_string` method

```perl
package Unit;
use Moo;
use Function::Parameters;

method _data_printer($properties) { $self->to_string }
```

Individual units are implemented like this

```perl
package Unit::Duration;
use Moo;
use Function::Parameters;
extends 'Unit';
use Time::Seconds;

has value => (is => 'ro', coerce => fun($val) { Time::Seconds->new($val) });
method to_string() { return $self->value->pretty; }
```

or

```perl
package Unit::Speed;
use Moo;
use Function::Parameters;
extends 'Unit';

# input in m/s
has value => (is => 'ro');
method to_string() { return sprintf "%.2f km/h", $self->value*3.6 }
```

I used such units to define a workout 

```perl
package Workout;
use Moo;
use Function::Parameters;
use Types::Standard qw(InstanceOf);

has description    => (is => 'ro');
has avg_speed      => (is => 'ro', isa => InstanceOf['Unit::Speed'], coerce => fun($json) { Unit::Speed->new(value => $json) }, init_arg => 'avgSpeed');
has max_speed      => (is => 'ro', isa => InstanceOf['Unit::Speed'], coerce => fun($json) { Unit::Speed->new(value => $json) }, init_arg => 'maxSpeed');
has total_time     => (is => 'ro', isa => InstanceOf['Unit::Duration'], coerce => fun($json) { Unit::Duration->new(value => $json) }, init_arg => 'totalTime');        # in seconds
# ...
```

When loaded/decoded from a web-site data, it dumps nicely formatted output data and still allows to work with object representing values

```
[0] Workout  {
    ...
    internals: {
        avg_speed        2.34 km/h,
        description      "Woods",
        max_speed        10.15 km/h,
        total_time       17 minutes, 22 seconds,
    }
},
```


[1]: https://metacpan.org/pod/Data::Printer
[2]: https://metacpan.org/pod/Moo
[3]: https://metacpan.org/pod/DateTime
