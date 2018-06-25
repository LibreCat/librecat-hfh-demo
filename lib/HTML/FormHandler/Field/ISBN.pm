package HTML::FormHandler::Field::ISBN;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
use Business::ISBN;
our $VERSION = '0.01';

our $class_messages = {
    'invalid_pattern' => 'Value [_1] is not a valid ISBN',
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
    my $isbn  = Business::ISBN->new( $field->value );
    return $field->add_error($field->get_message('invalid_pattern'), $field->value)
        unless $isbn && $isbn->is_valid();
    $field->value( $isbn->as_isbn13->as_string );
}


__PACKAGE__->meta->make_immutable;
use namespace::autoclean;

1;
