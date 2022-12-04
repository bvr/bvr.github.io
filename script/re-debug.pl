use 5.010; use strict; use warnings;

my $re = qr/^checksession\s+ok:(\d+).*?(fail1:(\d+))?$/;
while(<DATA>) {
    chomp;

    unless(/$re/) {
        say "[ ]$_" ;
        next;
    }

    my $marks = " " x length($_);
    while(/$re/g) {
        for my $nn (1 .. $#-) {
            my $start = $-[$nn];
            my $len   = $+[$nn] - $-[$nn];
            substr($marks,$start,$len) = $nn x $len;
        }
    }
    say "[M]$_\n   $marks";
}

__DATA__
checksession ok:6178 avg:479 avgnet:480 MaxTime:18081 fail1:19
checksession ok:6178 avg:479 avgnet:480 MaxTime:18081
checksession ok:6178 avg:479 avgnet:480 MaxTime:18081 fail1:2000
checksession ok:10 avg:479 avgnet:480 MaxTime:18081 fail1:15
