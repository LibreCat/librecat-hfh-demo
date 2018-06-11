package LibreCat::Form::Widget::Field::Upload;
use Moose::Role;
use HTML::FormHandler::Render::Util ("process_attrs");
use Catmandu::Util qw(:is);


sub render_element {
    my ( $self, $result ) = @_;

    $result ||= $self->result;

    my $attrs = $self->element_attributes($result);
    my $label = "browse..";
    if ( is_string( $attrs->{placeholder} ) ) {
        $label = $attrs->{placeholder};
    }
    $attrs->{class} = is_array_ref( $attrs->{class} ) ? $attrs->{class} : [];
    push @{ $attrs->{class} }, "hidden";

    my @output;
    push @output, qq(<label class="btn btn-default" for="), $self->id, qq(">), $label;
    push @output, qq(<input type="file" name=");
    push @output, $self->html_name . qq(");
    push @output, qq( id=") . $self->id . qq(");
    push @output, process_attrs($attrs);
    push @output, qq(>);
    push @output, qq(</label>);

    join("", @output);
}

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    die "No result for form field '" . $self->full_name . "'. Field may be inactive." unless $result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
