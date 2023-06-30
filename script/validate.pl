
use XML::LibXML;
use Try::Tiny;

my $config_filename = 'config.xml';
my $dom    = XML::LibXML->load_xml(   location => $config_filename);
my $schema = XML::LibXML::Schema->new(location => 'config.xsd');
try { 
    $schema->validate($dom) 
}
catch {
    die "There is a problem with the configuration: $_";
};
print "The $config_filename is valid\n";
