
package EndsWith {
    use Moo;
    use Function::Parameters;

    method test($class: $word, $s1, $s2 = undef) {
        my $pos = length($word) - length($s1);
        return $class->new(
            success => ($pos > 0 ? index($word, $s1, $pos) == $pos : 0),
            stem    => substr($word, 0, $pos),
            s1      => $s1,
            s2      => $s2,
        );
    }

    has success => (is => 'ro');
    has stem    => (is => 'ro');
    has s1      => (is => 'ro');
    has s2      => (is => 'ro');
    has kinds   => (is => 'lazy');

    method _build_kinds() {
        my $word = $self->stem;
        my $kind = "";
        for my $i (0 .. length($word) - 1) {
            my $letter = substr($word, $i, 1);
            $kind .= $letter =~ /[^aeiou]/ && (substr($kind, -1, 1) eq 'c' ? $letter ne 'y' : 1) ? 'c' : 'v';
        }
        return $kind;
    }

    method m() {
        return () = $self->kinds =~ /vc/g;
    }

    method contains_vowel() {
        return $self->kinds =~ /v/;
    }
}

use Test::More;
use List::AllUtils qw(first);
use Data::Dump qw(dd);

# test kinds
is(EndsWith->new(stem => 'toy')->kinds, "cvc", "toy -> cvc");
is(EndsWith->new(stem => 'syzygy')->kinds, "cvcvcv", "syzygy -> cvcvcv");

# test m calculation
my %test_m = (
    0 => [qw(tr ee tree y by)],
    1 => [qw(trouble oats trees ivy)],
    2 => [qw(troubles private oaten orrery)],
);
for my $m (sort keys %test_m) {
    for my $word (@{ $test_m{$m} }) {
        my $test = EndsWith->new(stem => $word);
        is $test->m, $m, "$word m=$m";
    }
}

# dictionary test
open my $voc, '<', 'porter-test/voc.txt' or die;
open my $out, '<', 'porter-test/output.txt' or die;

my $stop_after = 100;
while(defined (my $word = <$voc>)) {
    my $expected = <$out>;
    chomp($word);
    chomp($expected);

    my $stemmed = stem_word($word);
    if($stemmed ne $expected) {
        is $stemmed, $expected, "$word => $expected";
    }

    # last if $stop_after-- < 0;
}


done_testing;

sub test_word {
    my ($from, $to) = @_;
    is stem_word($from), $to, "$from => $to";
}


sub stem_word {
    my ($word) = @_;

    # step 1a
    if(my $rule = first { $_->success }
        EndsWith->test($word, 'sses' => 'ss'),
        EndsWith->test($word, 'ies'  => 'i'),
        EndsWith->test($word, 'ss'   => 'ss'),
        EndsWith->test($word, 's'    => '')
    ) {
        $word = $rule->stem . $rule->s2;
    }

    # step 1b
    my $eed = EndsWith->test($word, 'eed', 'ee');
    if($eed->success) {
        if($eed->m > 0) {
            $word = $eed->stem . $eed->s2;
        }
    }
    else {
        $rule = first { $_->success }
            EndsWith->test($word, 'ed'),
            EndsWith->test($word, 'ing');
        if($rule && $rule->success && $rule->contains_vowel) {
            $word = $rule->stem;
            my $subrule = first { $_->success }
                EndsWith->test($word, 'at' => 'ate'),
                EndsWith->test($word, 'bl' => 'ble'),
                EndsWith->test($word, 'iz' => 'ize');
            if($subrule) {
                $word = $subrule->stem . $subrule->s2;
            }
            elsif($word =~ /([^slz])\1$/)  {
                $word =~ s/.$//;
            }
            elsif($rule->kinds =~ /cvc$/ && $word =~ /[^wxy]$/) {
                $word .= 'e';
            }
        }
    }

    # step 1c
    my $yi = EndsWith->test($word, 'y' => 'i');
    if($yi->success && $yi->contains_vowel) {
        $word = $yi->stem . $yi->s2;
    }

    # step 2
    if(my $rule = first { $_->success }
        EndsWith->test($word, 'ational' => 'ate'),
        EndsWith->test($word, 'ational' => 'ate'),
        EndsWith->test($word, 'tional'  => 'tion'),
        EndsWith->test($word, 'enci'    => 'ence'),
        EndsWith->test($word, 'anci'    => 'ance'),
        EndsWith->test($word, 'izer'    => 'ize'),
        EndsWith->test($word, 'abli'    => 'able'),
        EndsWith->test($word, 'alli'    => 'al'),
        EndsWith->test($word, 'entli'   => 'ent'),
        EndsWith->test($word, 'eli'     => 'e'),
        EndsWith->test($word, 'ousli'   => 'ous'),
        EndsWith->test($word, 'ization' => 'ize'),
        EndsWith->test($word, 'ation'   => 'ate'),
        EndsWith->test($word, 'ator'    => 'ate'),
        EndsWith->test($word, 'alism'   => 'al'),
        EndsWith->test($word, 'iveness' => 'ive'),
        EndsWith->test($word, 'fulness' => 'ful'),
        EndsWith->test($word, 'ousness' => 'ous'),
        EndsWith->test($word, 'aliti'   => 'al'),
        EndsWith->test($word, 'iviti'   => 'ive'),
        EndsWith->test($word, 'biliti'  => 'ble')
    ) {
        if($rule && $rule->m > 0) {
            $word = $rule->stem . $rule->s2;
        }
    }

    # step 3
    if(my $rule = first { $_->success }
        EndsWith->test($word, 'icate' => 'ic'),
        EndsWith->test($word, 'ative' => ''),
        EndsWith->test($word, 'alize' => 'al'),
        EndsWith->test($word, 'iciti' => 'ic'),
        EndsWith->test($word, 'ical' => 'ic'),
        EndsWith->test($word, 'ful' => ''),
        EndsWith->test($word, 'ness' => '')
    ) {
        if($rule && $rule->m > 0) {
            $word = $rule->stem . $rule->s2;
        }
    }

    # step 4
    if(my $rule = first { $_->success }
        EndsWith->test($word, 'al'    => ''),
        EndsWith->test($word, 'ance'  => ''),
        EndsWith->test($word, 'ence'  => ''),
        EndsWith->test($word, 'er'    => ''),
        EndsWith->test($word, 'ic'    => ''),
        EndsWith->test($word, 'able'  => ''),
        EndsWith->test($word, 'ible'  => ''),
        EndsWith->test($word, 'ant'   => ''),
        EndsWith->test($word, 'ement' => ''),
        EndsWith->test($word, 'ment'  => ''),
        EndsWith->test($word, 'ent'   => ''),
        EndsWith->test($word, 'ion'   => ''),
        EndsWith->test($word, 'ou'    => ''),
        EndsWith->test($word, 'ism'   => ''),
        EndsWith->test($word, 'ate'   => ''),
        EndsWith->test($word, 'iti'   => ''),
        EndsWith->test($word, 'ous'   => ''),
        EndsWith->test($word, 'ive'   => ''),
        EndsWith->test($word, 'ize'   => '')
    ) {
        if($rule && $rule->s1 eq 'ion' && $rule->stem =~ /[st]$/ && $rule->m > 1) {
            $word = $rule->stem . $rule->s2;
        }
        elsif($rule && $rule->m > 1) {
            $word = $rule->stem . $rule->s2;
        }
    }

    # step 5a
    if(my $rule = EndsWith->test($word, 'e' => '')) {
        if($rule->success && $rule->m > 1) {
            $word = $rule->stem . $rule->s2;
        }
        elsif($rule->success && $rule->m == 1 && !( $rule->kinds =~ /cvc$/ && $rule->stem =~ /[^wxy]$/)) {
            $word = $rule->stem . $rule->s2;
        }
    }

    # step 5b
    if(my $rule = EndsWith->new(stem => $word)) {
        if($rule->m > 1 && $rule->stem =~ /ll$/) {
            $word =~ s/.$//;
        }
    }

    return $word;
}

