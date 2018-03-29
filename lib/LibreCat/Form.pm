package LibreCat::Form;
use Catmandu::Sane;
use HTML::FormHandler::Moose;

extends qw(HTML::FormHandler);

has "+widget_name_space" => (
    default => sub { [qw(LibreCat::Form::Widget)]; }
);

use namespace::autoclean;
1;
