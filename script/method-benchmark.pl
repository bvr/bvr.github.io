
use Benchmark qw(:all);

my $plain = Plain->new();
my $mss   = MSS->new();
my $mxd   = MXD->new();
my $fp    = FP->new();

cmpthese(-2, {
    plain => sub { $plain->run(10,20) },
    mss   => sub { $mss->run(10,20)   },
    mxd   => sub { $mxd->run(10,20)   },
    fp    => sub { $fp->run(10,20)    },
});

BEGIN {
    package Plain;
    sub new { bless {},shift }
    sub run {
        my ($self,$a,$b) = @_;
        my ($c,$d) = ($a,$b);
    }


    package MSS;
    use Method::Signatures::Simple;
    sub new { bless {},shift }
    method run($a,$b) {
        my ($c,$d) = ($a,$b);
    }


    use MooseX::Declare;
    class MXD {
        method run($a,$b) {
            my ($c,$d) = ($a,$b);
        }
    }

    package FP;
    use Function::Parameters;
    sub new { bless {},shift }
    method run($a,$b) {
        my ($c,$d) = ($a,$b);
    }
}
