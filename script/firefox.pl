
use 5.16.3;
use Path::Tiny qw(path);
use Config::Tiny;
use DBI;
use List::Util qw(first);
use Table::Builder;
use Data::Printer;

my $ff_dir   = $^O eq 'MSWin32' ? "$ENV{APPDATA}/Mozilla/Firefox" : "$ENV{HOME}/.mozilla/firefox";
my $ini_path = "$ff_dir/profiles.ini";

my $ff_profiles = Config::Tiny->new->read($ini_path);
my @profiles = map { $ff_profiles->{$_} } grep { /^Profile/ } sort keys %$ff_profiles;
p @profiles;

my $places_file = path($ff_dir)->child($profiles[1]->{Path})->child('places.sqlite');
warn "$places_file ", $places_file->exists, "\n";

my $dbh = DBI->connect("dbi:SQLite:dbname=$places_file","","")
    or die $DBI::errstr;

my $history = $dbh->selectall_arrayref(
    "SELECT url, title, description, last_visit_date FROM moz_places ORDER BY last_visit_date DESC LIMIT 1"
);
p $history;