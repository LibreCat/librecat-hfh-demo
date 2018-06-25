package HTML::FormHandler::Field::ISSN;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
use Business::ISSN;
our $VERSION = '0.01';

our $class_messages = {
    'invalid_pattern' => 'Value [_1] is not a valid ISSN',
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
    my $issn  = Business::ISSN->new( $field->value );
    return $field->add_error($field->get_message('invalid_pattern'), $field->value)
        unless $issn && $issn->is_valid();
}


__PACKAGE__->meta->make_immutable;
use namespace::autoclean;

1;
