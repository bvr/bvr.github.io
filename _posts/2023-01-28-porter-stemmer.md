---
layout: post
title: Porter's stemmer
published: yes
tags:
  - stemmer
  - Martin Porter
  - perl
  - specification
  - algorithm
---
The [Porter Stemming Algorithm][1] tries to reduce words into their stems. For typical full-text search, each document is described by vector of words (this can come from title, abstract, text of the document, keywords, etc). Term with same stem usually have similar meaning like in:

 - connect
 - connects
 - connected
 - connecting
 - connection
 - connections

The reduction into the stem is usually done by removing of various suffixes. The Porter algorithm does it for english source.

The algorithm defines **consonants** and **vowels**. Based on those, it considers each word of alternating sequence of consonant and vowel blocks. If we ignore optional consonant group at the beginning and option vowel group at the end, number of vowel-consonant blocks is called a **measure**. It is used to calculate "length" of the word and limit some rules before applying.

The **rules** for removing suffix are defined in form

```
(condition) S1 -> S2
```

where **condition** can use the measure and tests related to the stem that remains after removing suffix. The rules are grouped in a **set** where only first applicable rule is applied.

To improve my understanding of a specification I tried to implement the algorithm as much as it was specified. Since evaluation of the rule needs many side-effects like removing suffix and analyzing the remaining stem, I created small class to help with rule processing.

```perl
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
    has stem    => (is => 'ro', required => 1);
    has s1      => (is => 'ro', default => '');
    has s2      => (is => 'ro', default => '');
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
        return scalar(() = $self->kinds =~ /vc/g);
    }

    method contains_vowel() {
        return $self->kinds =~ /v/;
    }

    method apply() {
        return $self->stem . $self->s2;
    }

    method to_string() {
        return sprintf "rule: stem=%s (%s) m=%d, %s -> %s, success=%d, caller=%s",
            $self->stem, $self->kinds, $self->m(), $self->s1, $self->s2, $self->success, join(":",(caller(1))[1,2]);
    }
}
```

The class provides alternate constructor `test` that define an application of a rule on a word. Example usage can be

```perl
my $eed = EndsWith->test($word, 'eed', 'ee');
if($eed->success) {
    if($eed->m > 0) {
        $word = $eed->apply();
    }
}
```

Which implements application of following rule to the `$word`.

```
(m>0) EED -> EE
```

Another example for picking first rule of a set 

```perl
if(my $rule = first { $_->success }
    EndsWith->test($word, 'sses' => 'ss'),
    EndsWith->test($word, 'ies'  => 'i'),
    EndsWith->test($word, 'ss'   => 'ss'),
    EndsWith->test($word, 's'    => '')
) {
    $word = $rule->apply();
}
```

During the algorithm implementation I run into few inconsistencies between the specification and provided test set. 

 - the implementation skips words shorter than 3 characters, I haven't found this mentioned anywhere
 - in step 2 the `ABLI -> ABLE` is really implemented as `BLI -> BLE`
 - there is missing rule `LOGI -> LOG` in step 2
 - testing of `*o` condition is described as stem ending consonant, vowel, consonant different from w, x, or y. In actual test it limits the length of the word

All except the last one are mentioned in [Points of difference from the published algorithm section][2] which I noticed after I spent some time analyzing the differences.

My implementation of the algorithm goes as follows

```perl
use List::AllUtils qw(first);

sub stem_word {
    my ($word) = @_;

    return $word if length $word < 3;
    $word = lc $word;

    # step 1a
    if(my $rule = first { $_->success }
        EndsWith->test($word, 'sses' => 'ss'),
        EndsWith->test($word, 'ies'  => 'i'),
        EndsWith->test($word, 'ss'   => 'ss'),
        EndsWith->test($word, 's'    => '')
    ) {
        $word = $rule->apply();
    }

    # step 1b
    my $eed = EndsWith->test($word, 'eed', 'ee');
    if($eed->success) {
        if($eed->m > 0) {
            $word = $eed->apply();
        }
    }
    elsif(my $rule = first { $_->success }
        EndsWith->test($word, 'ed' => ''),
        EndsWith->test($word, 'ing' => '')
    ) {
        if($rule->contains_vowel) {
            $word = $rule->apply();
            if($subrule = first { $_->success }
                EndsWith->test($word, 'at' => 'ate'),
                EndsWith->test($word, 'bl' => 'ble'),
                EndsWith->test($word, 'iz' => 'ize')
            ) {
                $word = $subrule->apply();
            }
            elsif($rule->kinds =~ /cc$/ && $word =~ /([^slz])\1$/)  {
                $word =~ s/.$//;
            }
            elsif($rule->kinds =~ /^c+vc$/ && $word =~ /[^wxy]$/) {
                $word .= 'e';
            }
        }
    }

    # step 1c
    my $yi = EndsWith->test($word, 'y' => 'i');
    if($yi->success && $yi->contains_vowel) {
        $word = $yi->apply();
    }

    # step 2
    if(my $rule = first { $_->success }
        EndsWith->test($word, 'ational' => 'ate'),
        EndsWith->test($word, 'ational' => 'ate'),
        EndsWith->test($word, 'tional'  => 'tion'),
        EndsWith->test($word, 'enci'    => 'ence'),
        EndsWith->test($word, 'anci'    => 'ance'),
        EndsWith->test($word, 'izer'    => 'ize'),
        EndsWith->test($word, 'bli'     => 'ble'),
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
        EndsWith->test($word, 'biliti'  => 'ble'),
        EndsWith->test($word, 'logi'    => 'log')
    ) {
        if($rule->m > 0) {
            $word = $rule->apply();
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
        if($rule->m > 0) {
            $word = $rule->apply();
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
        if($rule->s1 eq 'ion') {
            if($rule->stem =~ /[st]$/ && $rule->m > 1) {
                $word = $rule->apply();
            }
        }
        elsif($rule->m > 1) {
            $word = $rule->apply();
        }
    }

    # step 5a
    my $rule = EndsWith->test($word, 'e' => '');
    if($rule->success && $rule->m > 1) {
        $word = $rule->apply();
    }
    elsif($rule->success && $rule->m == 1 && !($rule->kinds =~ /^c+vc$/ && $rule->stem =~ /[^wxy]$/)) {
        $word = $rule->apply();
    }

    # step 5b
    my $ll = EndsWith->new(stem => $word);
    if($ll->m > 1 && $ll->stem =~ /ll$/) {
        $word =~ s/.$//;
    }

    return $word;
}
```

As usual I used the testing to confirm the operations are working correctly. Here is small test to verify `kinds` method that determines consonants and vowels for the stem and `m` to calculate measure of the stem. Last portion is checking all words from the supplied test suite against sample vocabulary and output supplied [on algorithm page][2].

```perl
use Test::More;

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

while(defined (my $word = <$voc>)) {
    my $expected = <$out>;
    chomp($word);
    chomp($expected);

    my $stemmed = stem_word($word);
    is $stemmed, $expected, "$word => $expected";
}

done_testing;
```

Overall it was nice exercise that led me to better understanding of stemming algorithms and possible strategy for them.

Here are other interesting implementations I run into:

 - [F#][3]
 - [XSLT][4]

[1]: https://tartarus.org/martin/PorterStemmer/def.txt
[2]: https://tartarus.org/martin/PorterStemmer/
[3]: https://github.com/andagr/PorterStemmer/blob/master/PorterStemmer/Stemmer.fs
[4]: https://github.com/joeytakeda/xslt-stemmer/blob/master/porterStemmer.xsl
