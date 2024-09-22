
use Iterator::Simple qw(iterator ihead list);
use Path::Class::Rule;


my $finder = Path::Class::Rule->new->file->iname("*.md");

# using list ihead
{
    my $files = $finder->iter("..\\_posts");
    while(my @files = @{ list ihead(10, $files) }) {
        for my $file (@files) {
            warn "$file\n";
        }
        warn "-"x30, "\n";
    }
}

# using block_of
{
    my $files = $finder->iter("..\\_posts");
    while(my @files = block_of($files, 10)) {
        for my $file (@files) {
            warn "$file\n";
        }
        warn "-"x30, "\n";
    }
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
