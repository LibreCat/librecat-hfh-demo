package Upload;
use Catmandu::Sane;
use Catmandu::Util qw(:is);
use Catmandu;
use HFH;
use Dancer qw(:syntax);
use POSIX;
use IO::File;
use Data::UUID;
use MIME::Types;

post "/upload" => sub {

    my $params = params();
    my $upload = upload("file") or return send_errors("upload_required");

    my $fstore = HFH::file_store("tmp");
    my $index = $fstore->index;

    my $id = new_id();
    my $extension = mime2extension($upload->type) or return send_errors( "internal_error" );
    my $fid = new_id().".".$extension;
    $index->add({ _id => $id }) or return send_errors( "internal_error" );

    my $files = $index->files( $id );

    unless(
        $files->upload( IO::File->new( $upload->tempname ), $fid ) == $upload->size
    ){

        return send_errors("upload_failed");

    }

    my $f = $files->get( $fid );

    send_ok({
        file_id => $id.":".$fid,
        file_name => $upload->basename(),
        relation => "main_file",
        creator => "system",
        created => POSIX::strftime( "%FT%TZ", gmtime($f->{created}) ),
        modified => POSIX::strftime( "%FT%TZ", gmtime($f->{modified}) ),
        title => "",
        description => "",
        access_level => "open_access"
    });
};

sub send_ok {

    my $file = $_[0];
    status 200;
    content_type "application/json";
    to_json({
        status => "ok",
        errors => [],
        file => $file
    });
}

sub send_errors {

    my @errors = @_;
    status 400;
    content_type "application/json";
    to_json({
        status => "ok",
        file => undef,
        errors => \@errors
    });

}

sub new_id {
    state $uuid_gen = Data::UUID->new;
    $uuid_gen->create_str;
}

sub mime2extension {
    state $mt = MIME::Types->new();
    my $mime = $mt->type( $_[0] );
    my @extensions = $mime->extensions();
    $extensions[0];
}

1;
