
use 5.16.3;
use LWP::UserAgent;
use IO::Socket::SSL qw( SSL_VERIFY_NONE );

my $url      = 'https://honeywellprod.sharepoint.com/:x:/r/teams/sw_reuse/RTOS_COP/Shared%20Documents/DeosDocsCSV/DimensionsThirdPartyBaselines.xlsx';
my $filename = 'DimensionsThirdPartyBaselines.xlsx';
my $eid      = 'E374642';
my $password = 'a secret';

my $ua = LWP::UserAgent->new(keep_alive => 1, ssl_opts => { verify_hostname => 0, SSL_verify_mode => SSL_VERIFY_NONE });

$ua->credentials('honeywellprod.sharepoint.com:443', '', 'GLOBAL\\' . uc($eid), $password);
$ua->agent('Mozilla/5.0 (Windows NT 5.1; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0');

my $req = HTTP::Request->new(GET => $url);
my $res = $ua->request($req, $filename);

# check the outcome
if ($res->is_success) {
}
else {
    print "Error: " . $res->status_line . "\n";
    print $res->headers()->as_string(), "\n";
    die "Unable to get the '$filename' from sharepoint\n";
}
