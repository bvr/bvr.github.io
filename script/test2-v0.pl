
use Test2::V0;

# Simple stuff

use ok 'Test2::V0';
ok 1, 'True test';
ok 0, 'False test', 'Output extra stuff';
is 1, 1, 'Comparison';
my $data = { a => 1, b => 2 };
is $data, { b => 2, a => 1 }, 'Compare structures';
is $data, { a => 1, b => 3 }, 'Failed comparison of structures';
like 'string', qr/str/, 'Regex comparison';
like $data, { a => 1 }, 'Only check part of structure';

is [1, 3, 2], bag { item 1; item 2; item 3; end }, 'set comparison';

# Todos

todo "Not implemented yet" => sub {
    ok 0, 'Fails';
};

# Mocking

package Acme::Christmas {
    use Moo;
}

sub grinch {
    return 0;
}

my $mock_meta = mock 'Acme::Christmas' => (
    track => 1,
    add => [
        read_letters => sub {},
        make_toys    => sub {},
        date         => sub { 'December, 25th' },
        carol        => sub { 'Merry Xmas' },
        is_winter    => sub { 1 },
    ],
);

my $xmas = Acme::Christmas->new();


isa_ok $xmas, 'Acme::Christmas';
can_ok $xmas, qw( read_letters make_toys );

is $xmas->date, 'December, 25th', 'got the right date';

note "let's see if the Grinch is close";
subtest 'assert that the grinch is far away' => sub {
    if (grinch()) {
        fail 'oh, noes';
    } else {
        pass 'coast is clear!';
    }
};

SKIP: {
    skip "tests for winter only", 1 unless $xmas->is_winter;
    like $xmas->carol, qr/Merry/, 'found the proper lyrics';
}

use Data::Dump qw(dd);
dd [keys %{ $mock_meta->sub_tracking } ];


done_testing;