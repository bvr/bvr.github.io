
package EndsWith {
    use Moo;
    use Function::Parameters;

    my $C = qr/[^aeiou] [^aeiouy] */x;
    my $V = qr/[aeiouy] [aeiou] */x;

    has success => (is => 'ro');
    has stem    => (is => 'ro');
    has s1      => (is => 'ro');
    has s2      => (is => 'ro');

    method test($class: $word, $s1, $s2 = undef) {
        my $pos = length($word) - length($s1);
        return $class->new(
            success => ($pos > 0 ? index($word, $s1, $pos) == $pos : 0),
            stem    => substr($word, 0, $pos),
            s1      => $s1,
            s2      => $s2,
        );
    }

    method m() {
        return 1;
    }

    method contains_vowel() {
        return $self->stem =~ /$V/;
    }
}

use Test::More;
use List::AllUtils qw(first);
use Data::Dump qw(dd);

# step 1a
test_word('caresses' => 'caress');
test_word('ponies'   => 'poni');
test_word('ties'     => 'ti');
test_word('caress'   => 'caress');
test_word('cats'     => 'cat');

# step 1b
test_word('feed'      => 'feed');
test_word('agreed'    => 'agree');
test_word('plastered' => 'plaster');
test_word('bled'      => 'bled');
test_word('motoring'  => 'motor');
test_word('sing'      => 'sing');

# step 1c
test_word('happy'     => 'happi');
test_word('sky'       => 'sky');

# step 2
test_word('relational'     =>  'relate');
test_word('conditional'    =>  'condition');
test_word('rational'       =>  'rational');
test_word('valenci'        =>  'valence');
test_word('hesitanci'      =>  'hesitance');
test_word('digitizer'      =>  'digitize');
test_word('conformabli'    =>  'conformable');
test_word('radicalli'      =>  'radical');
test_word('differentli'    =>  'different');
test_word('vileli'         =>  'vile');
test_word('analogousli'    =>  'analogous');
test_word('vietnamization' =>  'vietnamize');
test_word('predication'    =>  'predicate');
test_word('operator'       =>  'operate');
test_word('feudalism'      =>  'feudal');
test_word('decisiveness'   =>  'decisive');
test_word('hopefulness'    =>  'hopeful');
test_word('callousness'    =>  'callous');
test_word('formaliti'      =>  'formal');
test_word('sensitiviti'    =>  'sensitive');
test_word('sensibiliti'    =>  'sensible');




# dictionary test
# open my $voc, '<', 'porter-test/voc.txt' or die;
# open my $out, '<', 'porter-test/output.txt' or die;

my $stop_after = 10;
while(defined (my $word = <$voc>)) {
    my $expected = <$out>;
    chomp($word);
    chomp($expected);
    is stem_word($word), $expected, "$word => $expected";

    last if $stop_after-- < 0;
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
    if($eed->success && $eed->m > 0) {
        $word = $eed->stem . $eed->s2;
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
            elsif($word =~ /^[^aeiouy]+[aeiouy][^aeiouwxy]$/) {
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

    return $word;
}

