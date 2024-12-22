
use MooX::Struct
    Empty => ['name', 'length'],
    Data  => ['id', 'length'],
    Block => ['id', 'pos'],
;

my @array = (
    Empty->new(name => '--', length => 5),
    Data->new(length => 5, id => 125),
    Data->new(length => 8, id => 129),
    Empty->new(name => '--', length => 3),
    Data->new(length => 8, id => 172),
);

use Data::Printer;
p @array;
