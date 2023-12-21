
use Data::Dump qw(dd pp);

my $simple = {
    a => [1..10],
    b => [2..15],
    c => [qw(e f g)],
};

dd $simple;     # { a => [1 .. 10], b => [2 .. 15], c => ["e", "f", "g"] }

my $complex = {
    name => 'Roman',
    address => '123 Street, New Hampshire',
    phone => '+111 123 123456',
};

dd $complex;
# {
#   address => "123 Street, New Hampshire",
#   name    => "Roman",
#   phone   => "+111 123 123456",
# }