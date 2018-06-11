package LibreCat::Form::Widget::Field::DropZone;
use Moose::Role;
use HTML::FormHandler::Render::Util ("process_attrs");
use Catmandu::Util qw(:is);


sub render_element {
    my ( $self, $result ) = @_;

    $result ||= $self->result;

    my $attrs = $self->element_attributes($result);
    push @{ $attrs->{class} }, "dropzone";
    $attrs->{action} = "#";

    my $id = $self->id();

    my @output;

    push @output,
        qq(<div id="),
        $id,
        qq(" ),
        process_attrs($attrs),
        qq(></div>);

    my $js = <<EOF;
<script type="text/javascript">

(function(\$){

    \$(document).load(function(){

        \$("#${id}").dropzone({
            autoProcessQueue: false,
            init: function(){

                var dr = this;
                var form = \$(this).closest("form");

                form.on("submit",function(evt){

                    evt.preventDefault();
                    evt.stopPropagation();
                    dr.processQueue();

                });

                \$(this).on("sendingmultiple", function(data, xhr, formData) {

                    var d = form.serializeArray();

                    for( var i = 0; i < d.length; i++ ){

                        formData.append( d[i]["name"], d[i]["value"] );

                    }

                });

            }
        });

    });

});

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
