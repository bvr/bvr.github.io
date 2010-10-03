
my $dot_props = 'len=2,font="Arial Black",style=box';
while($dot_props =~ /\G \s* (\w+) \s* = \s* (\w+|".*?") \s* ,? /gcx) {
    print "$1\t$2\n";
}
