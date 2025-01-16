
use XML::LibXML;
use Try::Tiny;

my $filename = 'poplety.rss';
my $dom    = XML::LibXML->load_xml(   location => $filename);
my $schema = XML::LibXML::Schema->new(location => 'rss-2_0_1-rev9.xsd');
try { 
    $schema->validate($dom) 
}
catch {
    die "There is a problem with the configuration: $_";
};
print "The $filename is valid\n";
