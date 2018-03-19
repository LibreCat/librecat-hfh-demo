package HTML::FormHandler::Field::Pattern;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.01';

has 'regex' => (
    is => 'ro',
    isa => 'Str',
    required => 1
);
has _regex => (
    is => 'ro',
    lazy => 1,
    builder => '_build_regex'
);
sub _build_regex {
    my $p = $_[0]->regex();
    qr/$p/;
}

our $class_messages = {
    'invalid_pattern' => 'Value must conform to regular expression',
};
sub get_class_messages {
    my $self = shift;
    return {
        %{ $self->next::method },
        %$class_messages,
    }
}

apply(
    [
        {
            transform => sub {
                my $value = $_[0];
                $value =~ s/^\+//;
                return $value;
            }
        }
    ]
);

sub validate {
    my $field = shift;
    my $value = $field->value;
    return $field->add_error($field->get_message('invalid_pattern')) unless $field->value =~ $field->_regex;
}


__PACKAGE__->meta->make_immutable;
use namespace::autoclean;

1;
