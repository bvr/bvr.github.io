
use Iterator::Simple qw(iterator islice);
use Path::Class::Rule;


my $finder = Path::Class::Rule->new->file->iname("*.md");
my $files = $finder->iter("..\\_posts");

# while(defined( my $file = $files->() )) {
#     warn "$file\n";
# }

while(my @files = block_of($files, 10)) {
    for my $file (@files) {
        warn "$file\n";
    }
    warn "-"x30, "\n";
}

sub block_of {
    my ($iterator, $block_size) = @_;

    my @block;
    while (defined(my $item = $iterator->())) {
        push @block, $item;
        return @block if @block == $block_size;
    }

    return @block;
}
