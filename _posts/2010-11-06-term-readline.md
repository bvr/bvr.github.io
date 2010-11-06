---
layout: post
title:  Term::ReadLine::Perl on Windows
category: perl
perex: >
    I plan to write simple console application to interface with databases I 
    maintain. Something like <b>mysql</b> command do, but with few advanced
    features like autocompletion (which does not work in mysql on Windows) or
    sending output to pager.
tags:
  - perl
  - command line
  - user interface
  - terminal
  - Term::ReadLine
  - Term::ReadLine::Perl
---
[Term::ReadLine](http://perldoc.perl.org/Term/ReadLine.html) came as natural
choice, so I took the example from SYNOPSIS and tried to add simple 
auto-completion. Traversal along the line and history worked fine, but I could 
not make it react on **Tab** at all.

Finally runned my script with [Devel::Trace](http://search.cpan.org/perldoc?Devel%3A%3ATrace) 
turned on and in its lenghty output I found this part:

{% highlight bash %}
>> C:/Perl/lib/Term/ReadLine/readline.pm:1536:     if ($dumb_term) {
>> C:/Perl/lib/Term/ReadLine/readline.pm:1537: 	return readline_dumb;
{% endhighlight %}

It looks like it is using some dumb terminal for some reason. Quick inspection 
of `readline_dumb` revealed, that apart of printing the prompt it simplifies its 
job to just calling `get_line` that look like this.

{% highlight perl %}
sub get_line {
    my $self = shift;
    my $fh = $self->[0];
    scalar <$fh>;
}
{% endhighlight %}

I was quite surprised, but it looks all history and editing magic is just 
feature of reading line from STDIN. And it is really so, running 

{% highlight bash %}
perl -le "print <STDIN>"
{% endhighlight %}

allows to use up/down arrows to get history and quite good line editing features.

With little more inspection I found that Windows set `TERM` environment variable
to `dumb`, which switch on this behavior. Setting it to anything else turn on
both autocompletion and various keyboard shortcuts normal on Unix command-lines.

Following snippet works and does simple case-insensitive auto-completion on few 
SQL commands.

{% highlight perl %}
use Term::ReadLine;

$ENV{TERM} = 'not dumb' if $^O eq 'MSWin32';

my $term   = Term::ReadLine->new('SQL Console');
my $prompt = "> ";
my $OUT    = $term->OUT || \*STDOUT;

$term->Attribs->{completion_function} = sub {
    my ($text, $line, $start) = @_;
    return grep { /^$text/i } (qw(
            SELECT INSERT UPDATE DELETE FROM WHERE AS IN ASC DESC
        ),'ORDER BY');
};

while (defined($_ = $term->readline($prompt))) {
    print $OUT $_, "\n";
    $term->addhistory($_) if /\S/;
}
{% endhighlight %}
