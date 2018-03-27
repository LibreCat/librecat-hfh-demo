package App;
use Catmandu::Sane;
use Catmandu::Util qw(:is);
use Catmandu;
use Dancer qw(:syntax);
use HTML::FormHandler;

hook before_template_render => sub {
  my $tokens = $_[0];
  $tokens->{uri_base} = request->uri_base();
  $tokens->{path_info} = request->path_info();
};



get "/forms/:key" => sub {

    my $form = get_form();

    template "forms/".param("key"),{ form => $form };

};
post "/forms/:key" => sub {

    my $form = get_form();
    my $params = params();

    my $result = $form->run( params => $params );

    template "forms/".param("key"),{ form => $result };

};

any qr{.*} => sub {
    status 'not_found';
    template 'not_found';
};
sub get_form {

    my $params = params();

    my $config = Catmandu->config->{forms}->{ $params->{key} };

    is_array_ref($config->{field_list}) || return;

    my %args = (
        action => uri_for(request->path_info)->as_string(),
        method => "POST",
        field_list => $config->{field_list},
        widget_wrapper => "LibreCat",
        form_element_class => ["form-horizontal"],
        is_html5 => 1,
        layout_classes => $config->{layout_classes} // +{}
    );

    HTML::FormHandler->new( %args );

}


1;
