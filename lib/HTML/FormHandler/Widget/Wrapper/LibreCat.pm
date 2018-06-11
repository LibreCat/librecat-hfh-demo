package HTML::FormHandler::Widget::Wrapper::LibreCat;
use Catmandu::Sane;
use Catmandu::Util qw(:is);
use Moose::Role;
use List::Util 1.33 ('any');
use HTML::FormHandler::Render::Util ('process_attrs');

with 'HTML::FormHandler::Widget::Wrapper::Bootstrap3';

sub add_standard_label_classes {
    my ( $self, $result, $class ) = @_;
    if ( not any { $_ =~ /^col\-/ } @$class ) {
        push @$class, "col-md-2";
    }
}

sub add_standard_element_wrapper_classes {
    my ( $self, $result, $class ) = @_;

    if ( not any { $_ =~ /^col\-/ } @$class ) {
        if ( !( $self->parent->has_flag( "is_repeatable") ) && !( $self->parent->has_flag( "is_compound") ) ) {

            push @$class, "col-md-10";
        }
        elsif ( $self->parent->has_flag( "is_repeatable") ) {

            push @$class, "col-md-12";

        }
    }
    if (
        ( ! $self->do_label || $self->type_attr eq 'checkbox' ) &&
         (not any { $_ =~ /^col\-.*offset/ } @$class) &&
         !( $self->parent->has_flag( "is_repeatable") ) &&
         !( $self->parent->has_flag( "is_compound") )
    ) {
        push @$class, "col-md-offset-2";
    }

}
sub add_standard_element_classes {
    my ( $self, $result, $class ) = @_;
    push @$class, 'has-error' if $result->has_errors;
    push @$class, 'has-warning' if $result->has_warnings;
    push @$class, 'disabled' if $self->disabled;
    push @$class, 'form-control'
       if $self->html_element eq 'select' || $self->html_element eq 'textarea' ||
          $self->type_attr eq 'text' || $self->type_attr eq 'password';
    push @$class, "selectpicker" if $self->html_element eq 'select';
    push @$class, "sticky"
        if $self->html_element eq 'select' || $self->html_element eq 'textarea' ||
          $self->type_attr eq 'text' || $self->type_attr eq 'password';
}

use namespace::autoclean;
1;
