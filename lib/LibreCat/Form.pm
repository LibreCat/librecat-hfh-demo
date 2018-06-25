package LibreCat::Form;
use Catmandu::Sane;
use Catmandu::Util qw(:is require_package);
use Catmandu;
use LibreCat::I18n;
use Clone qw();
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

By default compound and repeatable fields are rendered by concatenating their subfields

    FIELD  input    (FIELD.0)
    FIELD  input    (FIELD.1)
    TITLE  input    (TITLE)

Because of this repetition, do_wrapper and do_label for compounded fields are set to 0.
The drawback is the repetition of the label.

Better solution is:

* enable wrapper on field Compound/Repeatable (do_wrapper:1)

* enable label on field Compound/Repeatable (do_label:1)

* disable label for simple repeated fields (see below)

So a trigger adds some defaults to every field definition:

* field with type "Repeatable":

    * do_wrapper: 1
    * do_label: 1

* Simple repeated fields

    * do_label: 0

simple repeated fields like name[] are defined in HFH as such:

    - name: name
      type: Repeatable
    - name: name.contains
      type: Text

HFH does this to know exactly when a field will contain an array or a single value.

For structured repeated fields, the labels are shown.

e.g.

    - name: editor
      type: Repeatable
    - name: editor.first_name
      type: Text
    - name: editor.last_name
      type: Text


=cut
has "+field_list" => (
    trigger => \&_reset_field_list
);
=head1 widget_wrapper

subclass of widget_wrapper Bootstrap3.

Only adds some default class attributes, which can also be done here
in _reset_field_list..

=head1 Important notes

* FormHandler by default uses empty params as a signal that the form has not actually been posted, and so will not attempt to validate a form with empty params. Most of the time this works OK, but if you have a small form with only the controls that do not return a post parameter if unselected (checkboxes and select lists), then the form will not be validated if everything is unselected. For this case you can either add a hidden field as an 'indicator', or use the 'posted' flag.

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

    my $type_cache = {};

    for(my $i = 0; $i < scalar(@$field_list); $i++){

        my $field = $field_list->[$i];

        $type_cache->{ $field->{type} } ||= require_package( $field->{type}, "HTML::FormHandler::Field" )->new( %$field );
        my $obj = $type_cache->{ $field->{type} };
        my $is_repeatable = $obj->has_flag("is_repeatable") ? 1 : 0;
        my $is_compound = $obj->has_flag("is_compound") && !$is_repeatable ? 1 : 0;

        if ( $is_repeatable || $is_compound ) {

            my $do_label = exists($field->{do_label});
            my $do_wrapper = exists($field->{do_wrapper});
            $field->{do_wrapper} = 1 unless $do_wrapper;
            $field->{do_label} = 1 unless $do_label;

            if ( $is_repeatable ) {

                $field->{init_contains}->{tags}->{before_element_inside_div} = $add_pre
                    unless exists $field->{init_contains}->{tags}->{before_element_inside_div};
                $field->{init_contains}->{tags}->{after_element} = $add_post
                    unless exists $field->{init_contains}->{tags}->{after_element};

            }

            elsif ( $is_compound ) {


                if ( $field->{name} =~ /\.contains$/o ) {

                    $field->{do_label} = 0 unless $do_label;
                    $field->{tags}->{before_element_inside_div} = $add_pre
                        unless exists $field->{tags}->{before_element_inside_div};
                    $field->{tags}->{after_element} = $add_post
                        unless exists $field->{tags}->{after_element};

                }
                else {

                    $field->{tags}->{before_element_inside_div} = qq(<div class="input-group sticky">)
                        unless exists $field->{tags}->{before_element_inside_div};

                    $field->{tags}->{after_element} = qq(</div>)
                        unless exists $field->{tags}->{after_element};


                }

            }

        }
        elsif ( $field->{name} =~ /\./o ) {


            if ( $field->{name} =~ /\.contains$/o ) {

                $field->{do_label} = 0 unless exists $field->{do_label};
                $field->{tags}->{before_element_inside_div} = $add_pre
                    unless exists $field->{tags}->{before_element_inside_div};
                $field->{tags}->{after_element} = $add_post
                    unless exists $field->{tags}->{after_element};

            }
            else {

                $field->{do_wrapper} = 0 unless exists( $field->{do_wrapper} );
                $field->{label_class} = "input-group-addon" unless exists $field->{label_class};
                #skip last one list in the list..
                $field->{element_class} = "input-group-addon"
                    if(
                        !exists($field->{element_class}) &&
                        $i != scalar(@$field_list) - 1 &&
                        $field_list->[$i + 1]->{name} =~ /\./o
                    );

            }

        }

        if ( $field->{required} ) {

            $field->{tags}->{label_after} = qq(<span class="starMandatory"></span>)
                unless exists $field->{tags}->{label_after};

        }

        #match possible subclasses
        if ( $field->{type} =~ /Upload/o ) {

            $self->enctype( "multipart/form-data" );

        }

        #localize placeholder (not done by HFH)
        if( is_hash_ref( $field->{element_attr} ) && is_string( $field->{element_attr}->{placeholder} ) ){

            $field->{element_attr}->{placeholder} = $self->_localize( $field->{element_attr}->{placeholder} );

        }

    }

}

sub load {

    my ( $class, $key, $locale ) = @_;

    state $language_handles = {};
    $language_handles->{$locale} ||= LibreCat::I18N::_Handle->get_handle( $locale );

    my $config = Catmandu->config->{forms}->{ $key };

    return unless is_array_ref($config->{field_list});

    my %args = (
        field_list => Clone::clone( $config->{field_list} ),
    );

    $class->new( %args, language_handle => $language_handles->{$locale} );

}

use namespace::autoclean;
1;
