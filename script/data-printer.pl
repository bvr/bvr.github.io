
use DateTime;
use Data::Printer filters => ['DateTime'];

package Article {
    use Moo;
    
    has author   => (is => 'ro');
    has title    => (is => 'ro');
    has contents => (is => 'ro');
}

my $art = Article->new(author => 'Roman', title => 'Data::Printer', contents => 'Last time we touched ...');

p $art;

my $now = DateTime->now;

p $now;