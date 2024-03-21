---
layout: post
title: Log::Log4perl chunked output
published: yes
tags:
  - perl
  - Log::Log4perl
  - Log::Log4perl::Appender::Chunk
---
I have some scripts setup according to [this boilerplate]({% post_url 2022-12-13-perl-cli-boilerplate %}) that generate data for many different areas. The script now produces a log with progress information, warnings and errors. It would be nice if I could separate the log per an area. One benefit would be that I can include the log with each area and display it in an visual interface.

After brief look into [metacpan][1] I found an appender [Log::Log4perl::Appender::Chunk][2]. It allows to specify a region with calls to Mapped Diagnostic Context (MDC) mechanism like this:

```perl
Log::Log4perl::MDC->put('chunk', 'section');
# some logging
Log::Log4perl::MDC->put('chunk',undef);
```

Here is complete example, including the logging setup. It logs on screen, into main log file, and into the chunks

```perl
use Log::Log4perl qw(:easy);
use Data::Dump qw(dd);

setup_logger("TRACE");

INFO "Start program";
for my $phase (qw(One Two Three)) {
    INFO "Start $phase";
    Log::Log4perl::MDC->put('chunk', $phase);
    INFO "Text that goes into a chunk - $phase";
    Log::Log4perl::MDC->put('chunk', undef);
    INFO "End $phase";
}

# retrieve chunks and print them out
my $store = Log::Log4perl->appender_by_name('Chunk')->store();
my $chunks = $store->chunks();
for my $chunk (sort keys %$chunks) {
    print "$chunk\n" . ("-" x length $chunk) . "\n";
    print $chunks->{ $chunk }, "\n";
}

INFO "End program";


sub setup_logger {
    my ($level) = @_;

    my $conf = qq(
        log4perl.logger=$level, Logfile, Screen, Chunk

        log4perl.appender.Logfile           = Log::Dispatch::File::Stamped
        log4perl.appender.Logfile.filename  = log_chunks.log
        log4perl.appender.Logfile.mode      = append
        log4perl.appender.Logfile.stamp_fmt = %Y-%m-%d
        log4perl.appender.Logfile.max       = 4
        log4perl.appender.Logfile.layout    = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.Logfile.layout.ConversionPattern = %d{yyyy-MM-dd HH:mm:ss:SSS} [%p] %m%n

        log4perl.appender.Screen            = Log::Log4perl::Appender::Screen
        log4perl.appender.Screen.stderr     = 1
        log4perl.appender.Screen.layout     = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.Screen.layout.ConversionPattern = %m%n

        log4perl.appender.Chunk             = Log::Log4perl::Appender::Chunk
        log4perl.appender.Chunk.store_class = Memory        
        log4perl.appender.Chunk.layout      = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.Chunk.layout.ConversionPattern = %d{yyyy-MM-dd HH:mm:ss:SSS} [%p] %m%n
    );
    Log::Log4perl::init(\$conf);

    $SIG{__DIE__} = sub {
        # We're in an eval {} and don't want log this message but catch it later
        return if $^S;
        $Log::Log4perl::caller_depth++;
        FATAL "Error: @_";
        exit;
    };
}
```

Few interesting parts of the script above. The `setup_logger` configures three appenders for screen, log, and chunking. It also adds capturing of unhandled exceptions that would log `FATAL` entry and exits the script. The chunking is demonstrated in a loop over phases. Each phase goes into separate chunk, is retrieved after the main loop and printed out like this:

```
One
---
2024-03-21 12:42:35:265 [INFO] Text that goes into a chunk - One

Three
-----
2024-03-21 12:42:35:272 [INFO] Text that goes into a chunk - Three

Two
---
2024-03-21 12:42:35:270 [INFO] Text that goes into a chunk - Two
```

[1]: https://metacpan.org
[2]: https://metacpan.org/pod/Log::Log4perl::Appender::Chunk
