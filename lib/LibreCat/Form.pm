package LibreCat::Form;
use Catmandu::Sane;
use HTML::FormHandler::Moose;

extends qw(HTML::FormHandler);

=head1 widget_name_space

add a list of extra namespaces to look for widgets

By default: HTML::FormHandler::Widget

* namespace for field widgets: HTML::FormHandler::Widget::Field

    field widgets do the rendering for the form element itself. e.g. render the actual "input", "select" ..

* namespace for field wrapper widgets: HTML::FormHandler::Widget::Wrapper

    field wrapper widget wrap the rendered elements. e.g. puts element and label inside a div with class "form-group".

* namespace for form wrapper widgets: HTML::FormHandler::Widget::Form

    not used

So if you have a namespace LibreCat::Form::Widget, make sure you have
these subdirectories: Field, Wrapper and Form.

HTML::FormHandler tries to match the widget in your namespace, then in its own.

e.g. widget "Checkbox": LibreCat::Form::Widget::Field::Checkbox if present, otherwise
HTML::FormHandler::Widget::Field::Checkbox.

One can also use the full package name, and so avoid namespaces.

=cut
has "+widget_name_space" => (
    default => sub { [qw(LibreCat::Form::Widget)]; }
);

=head1 field_list

array reference of field definitions.

a trigger adds some default to every field definition:

* field with type "Repeatable":

    * do_wrapper: 1
    * do_label: 1

* field with parent Repeatable or Compound:

    * do_label: 0

By default compound and repeatable fields are rendered by concatenating their subfields

    FIELD  input    (FIELD.0)
    FIELD  input    (FIELD.1)
    TITLE  input    (TITLE)

That puts every subfield on a different line.

Because of this repetition, do_wrapper and do_label for compounded fields are set to 0.
The drawback is the repetition of the label.

Better solution is:

* enable wrapper on field Compound/Repeatable

* enable label on field Compound/Repeatable

* disable label on subfield

=cut
has "+field_list" => (
    trigger => \&_reset_field_list
);
=head1 widget_wrapper

subclass of widget_wrapper Bootstrap3.

Only adds some default class attributes, which can also be done here
in _reset_field_list..

=cut
has "+widget_wrapper" => ( default => sub { "LibreCat" } );
has "+is_html5" => ( default => sub { 1 } );

sub build_form_element_class { ["form-horizontal"] }

sub _reset_field_list {

    my ( $self, $field_list ) = @_;

    my $add_pre = qq(<div class="input-group sticky">);
    my $add_post = <<EOF;
    <div class="input-group-addon add-repeatable">
      <span class="fa fa-plus"></span>
    </div>
    <div class="input-group-addon remove-repeatable">
      <span class="fa fa-minus"></span>
    </div>
</div>
EOF

    for my $field ( @$field_list ) {

        if ( $field->{type} eq "Repeatable" || $field->{type} eq "Compound" ) {

            $field->{do_wrapper} = 1;
            $field->{do_label} = 1;

            if ( $field->{type} eq "Repeatable" || $field->{name} =~ /$/o ) {

                $field->{init_contains}->{tags}->{before_element_inside_div} = $add_pre;
                $field->{init_contains}->{tags}->{after_element} = $add_post;

            }

        }
        elsif ( $field->{name} =~ /\./o ) {

            $field->{do_label} = 0;

            if ( $field->{name} =~ /\.contains$/o ) {

                $field->{tags}->{before_element_inside_div} = $add_pre;
                $field->{tags}->{after_element} = $add_post;

            }

        }

        if ( $field->{required} ) {

            $field->{tags}->{label_after} = qq(<span class="starMandatory"></span>);

        }

    }

}

use namespace::autoclean;
1;
