---
layout: post
category: perl
tags:
  - perl
  - parsing
  - date manipulation
  - date
  - test
  - Test::More
---
Date parsing is always problematic. For most of my work I prefer canonical 
YYYY-MM-DD or YYMMDD format that is great for sorting and easy to parse. But
data comes from various sources. Recently I got data with all dates in 
US format: **Wed, Sep 17 2003**.

Here is very simple perl class that implement the parsing. Initially I looked
on [DateTime::Format::Natural][dfn] and some others, but I haven't found any 
working straight for me. I've choosen a OO form, since I need to parse many
such dates and initialization is potentially costly compared to matching code.

{% highlight perl %}
package DateParser;

sub new {
    my $class = shift;
    my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    my $num;
    return bless {
        months_tran => { map { lc($_) => ++$num } @months },
        months_re   => join '|', @months,
    }, ref($class) || $class;
}

sub parse {
    my ($self,$string) = @_;
    my $months_re = $self->{months_re};
    if($string =~ /^ \s*
        ((Mon|Tue|Wed|Thu|Fri|Sat|Sun) (?: \s*,\s* | \s+) )?  # day name
        ($months_re) \s+                                      # month name
        (\d+)     (?: \s*,\s* | \s+)                          # day
        (\d+)     \s*                                         # year
        $/xi
    ) {
        my $month = $self->{months_tran}{lc($3)};
        return () unless $month;
        return wantarray ? ($5,$month,$4) : sprintf("%04d-%02d-%02d",$5,$month,$4);
    }
    return ();
}

1;
{% endhighlight %}

The class `DateParser` has a constructor and one method. In constructor `new`
an anonymous hash is blessed into the class. The hash is constant and look like this:

{% highlight perl %}
{
  months_re => "Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec",
  months_tran => {
    'jan' => 1,   'feb' => 2,   'mar' => 3,   'apr' => 4,   
    'may' => 5,   'jun' => 6,   'jul' => 7,   'aug' => 8,   
    'sep' => 9,   'oct' => 10,  'nov' => 11,  'dec' => 12,
}
{% endhighlight %}

The `months_re` is part of parsing regular expression (RE) and `months_tran` is
hash for converting month name into its ordinal number.

A single method of the class does the parsing. Note that extended syntax of RE
is used (`//x`) that allows use comments and whitespace within it to enhance
clarity. The method in list context returns three items - year, month and day - 
in scalar context returns date as string formatted `YYYY-MM-DD`. 

### Test

I used the code below to debug the class. It is using simple procedural
[Test::More][tm] module with its `ok` and `is` functions. 

{% highlight perl %}
use Test::More;
use DateParser;

my $dp = DateParser->new;
ok $dp, "DateParser new";

my %tests = (
    ' Tue, Sep 16 2003 ' => '2003-09-16',
    'Wed, Sep 17 2003'   => '2003-09-17',
    'Thu, Jan 22 2004'   => '2004-01-22',
    'Wed, Mar 31 2004'   => '2004-03-31',
    'Jun 7 2004'         => '2004-06-07',
    '  Jun 7 , 2004 '    => '2004-06-07',
);
for my $input (sort keys %tests) {
    is  scalar $dp->parse($input),  $tests{$input},
        "\"$input\" => $tests{$input}";
}

done_testing;
{% endhighlight %}

Sample run:

    ok 1 - DateParser new
    ok 2 - "  Jun 7 , 2004 " => 2004-06-07
    ok 3 - " Tue, Sep 16 2003 " => 2003-09-16
    ok 4 - "Jun 7 2004" => 2004-06-07
    ok 5 - "Thu, Jan 22 2004" => 2004-01-22
    ok 6 - "Wed, Mar 31 2004" => 2004-03-31
    ok 7 - "Wed, Sep 17 2003" => 2003-09-17
    1..7

[dfn]: http://search.cpan.org/perldoc?DateTime::Format::Natural
[tm]:  http://search.cpan.org/perldoc?Test::More
