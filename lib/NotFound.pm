package NotFound;
use Catmandu::Sane;
use Dancer qw(:syntax);

any qr{.*} => sub {
    status 'not_found';
    template 'not_found';
};

1;
