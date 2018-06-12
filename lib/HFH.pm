package HFH;
use Catmandu::Sane;
use Catmandu;
use Catmandu::Util qw(:is require_package);

sub file_store {

    state $objects = {};

    my $name = $_[0];
    my $c = Catmandu->config->{filestore}->{$name};

    $objects->{$name} ||= require_package( $c->{package}, "Catmandu::Store::File" )->new( %{ $c->{options} } );

}

1;
