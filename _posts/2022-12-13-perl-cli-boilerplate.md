---
layout: post
title: Perl CLI boilerplate
published: yes
tags:
  - perl
  - Getopt::Long
  - Log::Log4perl
---
When I am starting work on a command-line (CLI) thing in perl, This is starter
boilerplate I am using. It goes for standard [Getopt::Long][1] to parse the parameters,
provides common format for help message and setups [Log::Log4perl][2] logging with current-date stamped logs.

It also provides function `run_command` to execute external tools and log their output.

```perl
use 5.16.3;
use lib 'lib';
use Getopt::Long;
use Data::Dump;
use Path::Class qw(dir file);
use Log::Log4perl qw(:easy);
use Capture::Tiny qw(capture_merged);

our $VERSION = '1.0.0';
GetOptions(
    'help'         => sub { help() },
    'input:s'      => \(my $input_config_file = 'user\\configs.xml'),
    'log-dir:s'    => \(my $log_dir           = 'user\\log'),
    'cache-dir:s'  => \(my $cache_dir         = "cache"),
    'matlab-exe:s' => \(my $matlab_exe        = 'd:\\Programs\\MATLAB\\2020b\\bin\\win64\\MATLAB.exe'),
    'skip-git'     => \(my $skip_git          = 0),
    'trace'        => \(my $trace             = 0),
) or help("Command-line parsing failed");

setup_logger($trace ? "TRACE" : "INFO");
INFO "----------------------------------------------------------";
INFO "$0 launched with: $input_config_file";
INFO "----------------------------------------------------------";

# TODO: the code goes here


INFO "Done";


sub run_command {
    my ($cmd) = @_;

    INFO "Command: $cmd";
    my $output = capture_merged { system "$cmd" };
    INFO "Output: " . format_output($output);
    return $output;
};

sub format_output {
    my ($output) = @_;

    my $indent = " "x9;
    $output =~ s/\n/\n$indent/g;
    return $output;
}

sub setup_logger {
    my ($level) = @_;

    dir($log_dir)->mkpath();
    my $conf = qq(
        log4perl.logger=$level, Logfile, Screen

        log4perl.appender.Logfile          = Log::Dispatch::File::Stamped
        log4perl.appender.Logfile.filename = $log_dir/titan-update.log
        log4perl.appender.Logfile.mode     = append
        log4perl.appender.Logfile.stamp_fmt = %Y-%m-%d
        log4perl.appender.Logfile.max      = 4
        log4perl.appender.Logfile.layout   = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.Logfile.layout.ConversionPattern = %d{yyyy-MM-dd HH:mm:ss:SSS} [%p] %m%n

        log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
        log4perl.appender.Screen.stderr  = 1
        log4perl.appender.Screen.layout  = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.Screen.layout.ConversionPattern = %m%n
    );
    Log::Log4perl::init(\$conf);

    $SIG{__DIE__} = sub {
        # We're in an eval {} and don't want log this message but catch it later
        return if $^S;
        $Log::Log4perl::caller_depth++;
        FATAL @_;
        die @_;
    };
}

sub help {
    print STDERR <<HEADER;
update_generic v.$VERSION
Copyright (C) 2022

HEADER

    if(@_) {
        warn "Error: @_\n";
    }

    my $usage = <<USAGE;
Usage:
  $0 [options] [config]

Description of the tool.

Options:
  --input            Input config file, defaults to user\\configs.xml
  --log-dir          Directory for update logs, defaults to user\\log
  --cache-dir        Directory for caching of generated files. Defaults to cache
  --matlab-exe       Matlab executable w/full path, defaults to d:\\Programs\\MATLAB\\2020b\\bin\\win64\\MATLAB.exe
  --skip-git         Skips removing of repos directory and git commands. Defaults to 0
  --trace            Enables more detailed logs. Defaults to 0

Examples:
  $0
  $0 --input=some_file.xml
  $0 --input=some_file.xml --skip-git
USAGE
    print STDERR $usage;
    exit(-1);
}
```