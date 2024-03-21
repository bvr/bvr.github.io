
use 5.16.3;
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

        log4perl.appender.Logfile          = Log::Dispatch::File::Stamped
        log4perl.appender.Logfile.filename = log_chunks.log
        log4perl.appender.Logfile.mode     = append
        log4perl.appender.Logfile.stamp_fmt = %Y-%m-%d
        log4perl.appender.Logfile.max      = 4
        log4perl.appender.Logfile.layout   = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.Logfile.layout.ConversionPattern = %d{yyyy-MM-dd HH:mm:ss:SSS} [%p] %m%n

        log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
        log4perl.appender.Screen.stderr  = 1
        log4perl.appender.Screen.layout  = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.Screen.layout.ConversionPattern = %m%n

        log4perl.appender.Chunk=Log::Log4perl::Appender::Chunk
        log4perl.appender.Chunk.store_class=Memory        
        log4perl.appender.Chunk.layout   = Log::Log4perl::Layout::PatternLayout
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
