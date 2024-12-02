my $array   = [1 .. 10];
my $complex = {
    name     => 'Rodrigo',
    age      => 12,
    lives_at => {
        street => 'Cactus Rd',
        number => 10,
        city   => 'Wichita'
    }
};

print $complex->{name};
while (my $first = shift @$array) {
    print $first;
}
