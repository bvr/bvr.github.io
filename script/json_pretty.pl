
use utf8;
use JSON::XS;
use YAML;

my $data = [
    {   doctype  => 'SRS',
        elements => [
            {   name    => 'srs01.md',
                trace => [
                    {   name => 'SRS_001',
                        tags => {allocation => 'SW'},
                    },
                    {   name => 'SRS_002',
                        tags => {allocation => 'HW'}
                    }
                ]
            }
        ]
    },
    {   doctype  => 'SRD',
        elements => [
            {   name    => 'srd01.md',
                trace => [
                    {   name   => 'SRD_001',
                        source => 'SRS_001',
                    }
                ]
            }
        ]
    }
];

my $json_coder = JSON::XS->new->ascii->pretty->canonical->allow_nonref;
print $json_coder->encode($data);

print YAML::Dump($data);
