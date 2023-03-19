
use 5.16.3;
use Iterator::Simple qw(iterator);

my $it = range(1,11);
while(defined(my $n = $it->next)) {
    say $n;
}

sub range {
    my ($from, $to, $step) = @_;
    $step //= 1;

    my $i = $from - $step;
    iterator {
        $i += $step;
        return if $i > $to;
        return $i;
    }
}
