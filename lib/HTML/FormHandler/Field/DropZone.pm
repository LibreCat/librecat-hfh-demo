package HTML::FormHandler::Field::DropZone;
use Catmandu::Util qw(:is);
use Moose;
use Moose::Util::TypeConstraints;
use Catmandu::Util qw(:is);
use HFH;

extends "HTML::FormHandler::Field";

#overrides
has "+widget" => (
    default => "DropZone"
);
has "+type_attr" => (
    default => "hidden"
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
has url => (
    is => "rw",
    isa => "Str",
    required => 1
);

sub BUILD {

    my $self = $_[0];
    #help-inline block is put below the dropzone, which is not very helpfull
    $self->set_tag( "no_errors", 1 );

}

our $class_messages = {
    "upload_file_not_found" => "File [_1] not found",
    "upload_file_empty" => "File [_1] is empty",
    "upload_file_too_small" => "File [_1] is too small (< [_2] bytes)",
    "upload_file_too_big" => "File [_1] is too big (> [_2] bytes)",
    "upload_file_invalid_mimetype" => "File type of [_1] is not allowed"
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

    #[ { file_id => "dir:file_id", access_level => "open_access", title => "file title", description => "file description" }, .. ]

    my $uploads = $self->value;
    $uploads = is_array_ref( $uploads ) ? $uploads : is_hash_ref($uploads) ? [$uploads] : [];

    my $accept = is_array_ref($self->accept) ? $self->accept : [];

    for my $upload ( @$uploads ) {

        my($dir, $basename) = split(":",$upload->{file_id});

        my $files = HFH::file_store("tmp")->index->files($dir);

        my $file = $files->get( $basename );

        unless( $file ) {

            my $err = $self->_localize(
                $self->get_message("upload_file_not_found"),
                $upload->{file_name}
            );
            $upload->{file_error} = $err;
            $self->push_errors($err);
            next;

        }

        unless ( $file->{size} > 0 ) {
            my $err = $self->_localize(
                $self->get_message("upload_file_empty"),
                $upload->{file_name}
            );
            $upload->{file_error} = $err;
            $self->push_errors($err);
            next;

        }
        if( defined $self->min_size && $file->{size} < $self->min_size ) {

            my $err = $self->_localize(
                $self->get_message("upload_file_too_small"),
                $upload->{file_name},
                $self->min_size
            );
            $upload->{file_error} = $err;
            $self->push_errors( $err );
            next;

        }

        if( defined $self->max_size && $file->{size} > $self->max_size ) {

            my $err = $self->_localize(
                $self->get_message('upload_file_too_big'),
                $upload->{file_name},
                $self->max_size
            );
            $upload->{file_error} = $err;
            $self->push_errors( $err );
            next;

        }

        if ( scalar( @$accept ) > 0 ) {

            my($base,$type,$subtype) = split(/\./,$basename);
            my $mime = "$type/$subtype";
            my $found = 0;

            for my $a ( @$accept ) {
                if ( $a eq $mime ) {
                    $found = 1;
                    last;
                }
            }

            unless($found){

                my $err = $self->_localize(
                    $self->get_message('upload_file_invalid_mime_type'),
                    $upload->{file_name}
                );
                $upload->{file_error} = $err;
                $self->push_errors( $err );
                next;

            }

        }

    }

}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
