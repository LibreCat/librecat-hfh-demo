package LibreCat::Form;
use Catmandu::Sane;
use Catmandu::Util qw(:is);
use HTML::FormHandler::Moose;

extends "HTML::FormHandler";

sub in_array {

    my ( $array, $val ) = @_;
    if ( defined $val ) {

        for( @$array ) {
            return 1 if $_ eq $val;
        }

    }
    else {

        for ( @$array ) {
            return 1 unless defined $_;
        }

    }
    return 0;
}

sub _force_array {

    my $val = $_[0];
    is_array_ref($val) ?
        [ @$val ] :
            is_string( $val ) ? [ $val ] : [];

}

sub html_attributes {

    my ( $self, $obj, $type, $attrs, $result ) = @_;

    if ( $obj->has_fields() ) {

        if ( $type eq "element_wrapper" ) {

            my $input_type = $obj->type;


        }
        elsif ( $type eq "wrapper" ) {

            my $class = _force_array( $attrs->{class} );
            push @$class, "form-inline";
            $attrs->{class} = $class;

        }

    }
    else {
        if ( $type eq "element" ) {

            my $input_type = $obj->type;
            my $class = _force_array( $attrs->{class} );
            push @$class, "sticky" if not in_array($class,"sticky");
            push @$class, "selectpicker" if !in_array($class,"selectpicker") && $input_type eq "Select";

            $attrs->{class} = $class;

        }
        elsif( $type eq "label" ) {

            my $class = _force_array( $attrs->{class} );
            push @$class, "col-md-2" if not in_array($class,"col-md-2");
            $attrs->{class} = $class;

        }
        elsif ( $type eq "element_wrapper" ) {

            my $input_type = $obj->type;
            my $class = _force_array( $attrs->{class} );
            if ( $input_type eq "Integer" ) {
                push @$class, "col-md-2" if not in_array($class,"col-md-2");
            }
            else {
                push @$class, "col-md-10" if not in_array($class,"col-md-10");
            }
            push @$class, "col-md-offset-2" if !in_array($class,"col-md-offset-2") && $input_type eq "Submit";
            $attrs->{class} = $class;

        }
    }

    $attrs;

}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
