package App;
use Catmandu::Sane;
use Catmandu::Util qw(:is);
use Catmandu;
use Dancer qw(:syntax);
use LibreCat::Form;
use Clone;

hook before_template_render => sub {
  my $tokens = $_[0];
  $tokens->{uri_base} = request->uri_base();
  $tokens->{path_info} = request->path_info();
  $tokens->{catmandu_conf} = Catmandu->config;
};

get "/" => sub {

    template "home";

};

get "/forms/:key" => sub {

    my $form = get_form() or pass;

    template "forms/".param("key"),{ form => $form };

};
post "/forms/:key" => sub {

    my $form = get_form() or pass;
    my $params = params();

    my $result = $form->run( params => $params );

    template "forms/".param("key"),{ form => $result };

};

sub get_form {

    my $params = params();

    my $config = Catmandu->config->{forms}->{ $params->{key} };

    is_array_ref($config->{field_list}) || return;

    my %args = (
        field_list => $config->{field_list},
        layout_classes => $config->{layout_classes} // +{}
    );

    LibreCat::Form->new( %args );

}

1;
