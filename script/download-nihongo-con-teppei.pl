
use 5.16.3;
use Mojo::UserAgent;
use Data::Dump qw(dd);

# This script is made to download .mp3 episodes of "Nihongo Con Teppei" web site 
# at http://teppeisensei.com

my $ua  = Mojo::UserAgent->new;
my $page = 'http://teppeisensei.com/index-66.html';

my $dom = $ua->get($page)->result->dom;
my @download_urls = $dom->find('a')
    # links with href and referring to .mp3
    ->grep(sub { defined $_->attr('href') && $_->attr('href') =~ /\.mp3/ })     
    ->map(sub { Mojo::URL->new($_->attr('href')) })
    ->map(sub { Mojo::URL->new($_->query->param('u')) })
    ->each;

for my $url (@download_urls) {
    my $filename = $url->path->parts->[-1];
    next if -e $filename;

    warn "$url -> $filename\n";
    my $tx = $ua->get($url);
    $tx->result->save_to($filename);
}
