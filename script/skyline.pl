
use utf8;
use List::Util qw(reduce min max);
use Data::Dump qw(dd);

my @buildings = (
    [1,11,5], [2,6,7], [3,13,9], [12,7,16], [14,3,25], [19,18,22], [23,13,29], [24,4,28],
);

draw_buildings(@buildings);
my @skyline = calc_skyline(@buildings);
dd @skyline;

sub calc_skyline {
    my @buildings = @_;

    my $min = min map { $_->[0] } @buildings;
    my $max = max map { $_->[2] } @buildings;

    my @output = ();
    my $last = -1;
    for my $x ($min .. $max) {
        my $skyline = max map { $_->[1] } grep { $_->[0] <= $x && $x < $_->[2] } @buildings;
        if($last != $skyline) {
            push @output, $x, $skyline//0;
            $last = $skyline;
        }
    }

    return @output;
}

sub draw_buildings {
    my @buildings = @_;

    # find dimension of the range (assume positive and zero-based data)
    my $dim = reduce {
        my ($left, $height, $right) = @$b;
        my $mx = max($a->[0], $right);
        my $my = max($a->[1], $height);
        [$mx, $my];
    } [0,0], @buildings;

    my ($screen_width, $screen_height) = @$dim;
    my @screen = map { [ (' ') x ($screen_width*2) ] } 0..$screen_height;

    # verticals
    for my $b (@buildings) {
        my ($left, $height, $right) = @$b;
        for my $y (0..$height) {
            $screen[$y][$left*2]  = '│';
            $screen[$y][$right*2] = '│';
        }
        $screen[$height][$left*2]  = '┌';
        $screen[$height][$right*2] = '┐';
    }

    # horizontal
    for my $b (@buildings) {
        my ($left, $height, $right) = @$b;
        for my $x ($left*2+1 .. $right*2-1) {
            $screen[$height][$x] = $screen[$height][$x] eq ' ' ? '─' : '┼';
        }
    }

    # print the screen
    binmode(STDOUT,':utf8');
    for my $ln (reverse 0 .. $screen_height) {
        print join('', @{$screen[$ln]}), "\n";
    }
    my $last_row = join('', @{$screen[0]}) . "  ";
    $last_row =~ tr/ │/═╧/;
    print $last_row, "\n";
}


=head1 Skyline

The Skyline Puzzle is a classic programming exercise; it draws a silhouette of
a city skyline by blocking out portions of buildings that are masked by taller
buildings. A city is a list of buildings specified as triples containing left
edge, height, and right edge. For instance, the list of triples

    (1 11 5) (2 6 7) (3 13 9) (12 7 16) (14 3 25) (19 18 22) (23 13 29) (24 4 28)

encodes the eight buildings shown at the left of the diagram, and the path

    1 11 3 13 9 0 12 7 16 3 19 18 22 3 23 13 29 0

encodes the skyline shown at the right of the diagram, where the odd-indexed
elements of the output are the x-coordinate of the skyline and the even-indexed
elements of the output are the y-coordinate of the skyline.

(It makes more sense to me that the output should look like

    (1 11) (3 13) (9 0) (12 7) (16 3) (19 18) (22 3) (23 13) (29 0)

but that’s not the way the puzzle is ever specified.) Notice that the
second (2 6 7) and eighth (24 4 28) buildings are not part of the skyline.

Your task is to write a program that takes a list of buildings and returns a
skyline. When you are finished, you are welcome to read or run a suggested
solution, or to post your own solution or discuss the exercise in the comments
below.

=cut
