package HTML::FormHandler::Field::DropZone;
use Catmandu::Util qw(:is);
use Moose;
use Moose::Util::TypeConstraints;

extends "HTML::FormHandler::Field";

#overrides
has "+widget" => (
    default => "DropZone"
);
has "+type_attr" => (
    default => "file"
);

#own attributes
has min_size => (
    is  => "rw",
    isa => "Maybe[Int]",
    default => 1
);
has max_size => (
    is  => "rw",
    isa => "Maybe[Int]",
    default => 1048576
);
has accept => (
    is => "rw",
    isa => "ArrayRef[Str]"
);

our $class_messages = {
    "upload_file_not_found" => "File [_1] not found",
    "upload_file_empty" => "File [_1] is empty",
    "upload_file_too_small" => "File [_1] is too small (< [_2] bytes)",
    "upload_file_too_big" => "File [_1] is too big (> [_2] bytes)"
};
sub get_class_messages  {
    my $self = shift;
    return {
        %{ $self->next::method },
        %$class_messages,
    }
}

sub validate {
    my $self   = shift;

    my $upload = $self->value;

    my $size = 0;
    if( blessed( $upload ) && $upload->can('size') ) {

        $size = $upload->size;

    }
    elsif( is_real_fh( $upload ) ) {

        $size = -s $upload;

    }
    else {

        $self->add_error(
            $self->get_message("upload_file_not_found", $upload->basename())
        );

    }
    unless ( $size > 0 ) {

        $self->add_error(
            $self->get_message("upload_file_empty", $upload->basename())
        );
        next;

    }

    if( defined $self->min_size && $size < $self->min_size ) {

        $self->add_error(
            $self->get_message("upload_file_too_small"),
            $upload->basename(),
            $self->min_size
        );
        next;

    }

    if( defined $self->max_size && $size > $self->max_size ) {

        $self->add_error(
            $self->get_message('upload_file_too_big'),
            $upload->basename(),
            $self->max_size
        );
        next;

    }

}

# stolen from Plack::Util::is_real_fh
sub is_real_fh {
    my $fh = shift;

    my $reftype = Scalar::Util::reftype($fh) or return;
    if( $reftype eq "IO"
            or $reftype eq "GLOB" && *{$fh}{IO} ){
        my $m_fileno = $fh->fileno;
        return unless defined $m_fileno;
        return unless $m_fileno >= 0;
        my $f_fileno = fileno($fh);
        return unless defined $f_fileno;
        return unless $f_fileno >= 0;
        return 1;
    }
    else {
        return;
    }
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
