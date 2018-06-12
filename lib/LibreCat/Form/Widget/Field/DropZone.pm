package LibreCat::Form::Widget::Field::DropZone;
use Catmandu::Sane;
use Moose::Role;
use HTML::FormHandler::Render::Util ("process_attrs");
use Catmandu::Util qw(:is);
use JSON;

sub render_element {
    my ( $self, $result ) = @_;

    $result ||= $self->result;

    my $attrs = $self->element_attributes($result);

    my $id = $self->id();
    my $name = $self->name();
    my $max_size = $self->max_size();
    my $acceptedFiles = join(",", @{ $self->accept || [] });
    my $url = $self->url();

    my $json = JSON->new();
    my $subfields_str;
    my $hidden_inputs_str;
    my $my_uploads_str = "[]";

    {
        my @hidden_inputs;
        my @subfields = qw(file_id file_name access_level title description relation creator created modified);
        $subfields_str = "[".join(",",map { "\"$_\"" } @subfields)."]";

        if ( is_array_ref( $result->value ) ) {

            for(my $i = 0;$i < scalar( @{ $result->value } );$i++ ) {

                my $upload = $result->value->[$i];
                for my $key( @subfields ){

                    push @hidden_inputs, qq(<input type="hidden" ) . process_attrs({
                        name => "$id.$i.$key",
                        value => $upload->{$key}
                    }) . ">";

                }

            }
            $my_uploads_str = $json->encode( $result->value );

        }

        $hidden_inputs_str = join("",@hidden_inputs);
    }

    my $preview_template = qq(<div class='col-md-11 dz-preview dz-file-preview'></div>);

    my @output;

    push @output,
        qq(<div id="),
        $id,
        qq(" ),
        process_attrs($attrs),
        qq(>Drop some files here</div>);

    my $js = <<EOF;
<script type="text/javascript">

(function(\$){

    \$(document).ready(function(){

        var my_uploads = $my_uploads_str;

        function generate_preview_elements(upload){

            var elements = [];

            var file_row = Dropzone.createElement(
                "<div class='row'><div class='col-md-12 padded text-muted' ><span class='fa fa-file text-muted'></span> <strong>" + upload.file_name + "</strong></div></div>"
            );
            elements.push(file_row);

            elements.push(
                Dropzone.createElement(
                "<div class='row'><div class='col-md-2 text-muted'>Access Level:</div><div class='col-md-3 text-muted'>Upload Date:</div><div class='col-md-3 text-muted'>User:</div><div class='col-md-4 text-muted'>Relation:</div></div>")
            );

            var accessString = Dropzone.createElement("<div class='row'><div class='col-md-2'><span>" + upload.access_level + "</span></div></div>");
            file_row.appendChild(accessString);

            var dateString = Dropzone.createElement("<div class='col-md-3'><span>" + upload.modified + "</span></div>");
            accessString.appendChild(dateString);

            var userString = Dropzone.createElement("<div class='col-md-3'><span>" + upload.creator + "</span></div>");
            accessString.appendChild(userString);

            var relationString = Dropzone.createElement("<div class='col-md-4'><span>" + upload.relation + "</span></div>");
            accessString.appendChild(relationString);

            elements.push(accessString);

            //REMOVE
            var removeLink = Dropzone.createElement("<div class='corner_up'><a href='#'><span class='fa fa-times'></span></a></div>");
            removeLink.addEventListener("click", function(e) {
                var file_id = upload.file_id;
                for(var i = 0;i < my_uploads.length;i++){
                    if ( my_uploads[i]["file_id"] == file_id ) {
                        my_uploads.splice(i,1);
                        break;
                    }
                }
                \$(this).closest(".dz-preview").remove();
                e.preventDefault();
            });
            elements.push(removeLink);

            //EDIT
            var editLink = Dropzone.createElement("<div class='corner_down'><a href='#' onclick='return false;'><span class='fa fa-pencil'></span></a></div>");
            editLink.addEventListener("click", function(e) {
                alert("TODO");
            });
            elements.push(editLink);

            if( upload.file_error != undefined ){
                elements.push(
                    Dropzone.createElement( "<span class='help-block'>" + upload.file_error + "</span>" )
                );
            }

            return elements;
        }

        new Dropzone( "#${id}", {
            url: window.app.uri_base + "$url",
            method: "POST",
            maxFilesize: $max_size,
            acceptedFiles: "${acceptedFiles}",
            previewTemplate: "${preview_template}",
            createImageThumbnails: false,
            addRemoveLinks: true,
            init: function(){

                \$("#${id}").append(
                    '<div class="dropzone-hidden-uploads" style="display:none">${hidden_inputs_str}</div>'
                );

                \$('.dz-default.dz-message').addClass('col-md-11');

                //add old files
                for( var i = 0; i < my_uploads.length; i++ ){
                    var upload = my_uploads[i];
                    var preview = Dropzone.createElement("$preview_template");
                    var elements = generate_preview_elements(upload);
                    for( var j = 0; j < elements.length; j++ ){
                        preview.appendChild(elements[j]);
                    }
                    if( upload.file_error != undefined ){
                        \$(preview).addClass("alert alert-danger");
                    }
                    else {
                        \$(preview).addClass("alert alert-success");
                    }
                    \$("#${id}").append(preview);
                }

                this.on("addedfile", function(file) {
                    var progress = Dropzone.createElement("<div class='row'><div class='progress progress-striped active'><div class='progress-bar' style='width:0;text-align:left;padding-left:10px;'>" + file.name + "</span></div></div></div>");
                    file.previewElement.appendChild(progress);
                });

                this.on("uploadprogress", function(file,progress,bytesSent){
                    \$(file.previewElement).find(".progress-bar").css({ width : progress + "%" });
                });

                this.on("success", function(file,res){
                    \$(file.previewElement).find(".progress").remove();

                    if(res.status == "ok"){

                        my_uploads.push( res.file );

                        \$(file.previewElement).addClass("alert alert-success");

                        var elements = generate_preview_elements(res.file);

                        for( var i = 0; i < elements.length; i++ ){
                            file.previewElement.appendChild(elements[i]);
                        }

                    }
                });

                this.on("error", function(file, errorMessage){
                    var modal = Dropzone.createElement("<div class='alert alert-danger'>" + errorMessage.errors.join(",") + "</div>");
                    file.previewElement.appendChild(modal);
                });

                this.on("complete", function(file){
                    \$( file.previewElement.getElementsByClassName('dz-remove') ).remove();
                });

            }

        });
        \$("#${id}").closest("form").on("submit",function(evt){

            var hidden_uploads = \$(this).find(".dropzone-hidden-uploads");
            hidden_uploads.empty();

            for(var i = 0; i < my_uploads.length;i++){
                var upload = my_uploads[i];
                var keys = $subfields_str;
                for ( var j = 0; j < keys.length; j++ ) {
                    var e = document.createElement("input");
                    e.type = "hidden";
                    e.name = "$name." + i + "." + keys[j];
                    e.value = upload[ keys[j] ];
                    hidden_uploads.append( e );
                }
            }

            return true;

        });
    });

})(jQuery);

</script>
EOF

    push @output, $js;

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
