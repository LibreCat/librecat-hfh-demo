package HTML::FormHandler::Field::PubId;
use HTML::FormHandler::Moose;
use Business::ISBN;
use Business::ISSN;

extends "HTML::FormHandler::Field::Compound";

our $class_messages = {
    "invalid_type" => "type must be either 'isbn' or 'issn'",
    "invalid_value" => "[_1] is not a valid [_2]"
};
sub get_class_messages {
    my $self = shift;
    return {
        %{ $self->next::method },
        %$class_messages,
    }
}

sub validate {

    my $self = $_[0];

    my @all_fields = $self->all_fields();

    my $type_field = $all_fields[0];
    my $value_field = $all_fields[1];

    my $type_value = $type_field->value();
    my $value = $value_field->value();

    if ( $type_value ne "isbn" && $type_value ne "issn" ) {

        $self->add_error(
            $self->get_message("invalid_type")
        );
        return;

    }

    my $validator = $type_value eq "isbn" ? Business::ISBN->new( $value ) : Business::ISSN->new( $value );

    unless( $validator && $validator->is_valid() ){

        $self->add_error(
            $self->get_message("invalid_value"), $value, uc($type_value)
        );
        return;

    }

}


__PACKAGE__->meta->make_immutable;
use namespace::autoclean;

1;
