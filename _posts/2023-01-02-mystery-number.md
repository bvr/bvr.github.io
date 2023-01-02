---
layout: post
title: The Mystery Six-Digit Number
published: yes
tags:
  - perl
  - Algorithm::Combinatorics
  - riddle
---
A riddle from [riddlesbrainteasers.com][1]: Find a six-digit number containing no zeros and no repeated digits that satisfies the following conditions:

 1. The first and fourth digits sum to the last digit, as do the third and fifth digits.
 2. The first and second digits when read as a two-digit number equal one quarter the fourth and fifth digits.
 3. The last digit is four times the third digit.

Since the potential problem space is small, a quick brute-force solution using [Algorithm::Combinatorics][2] would do. The library provides efficient iterator-based tool for comminatory problems. The script below tries all options and remove those that does not match the conditions specified. Matching numbers are printed, in this case there is only one solution, number `192768`.

```perl
use 5.16.3;
use Algorithm::Combinatorics qw(variations);

my $iter = variations([1..9], 6);
while(my $p = $iter->next) {
    my ($a, $b, $c, $d, $e, $f) = @$p;
    next unless $a + $d == $f;
    next unless $c + $e == $f;
    next unless 10*$a+$b == (10*$d+$e)/4;
    next unless $f == 4*$c;

    say join '',@$p;
}
```

[1]: https://riddlesbrainteasers.com/mystery-six-digit-number/
[2]: https://metacpan.org/pod/Algorithm::Combinatorics
