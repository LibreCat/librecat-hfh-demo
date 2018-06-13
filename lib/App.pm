package App;
use Catmandu::Sane;
use Catmandu::Util qw(:is);
use Catmandu;
use Dancer qw(:syntax);
use LibreCat::Form;
use URI::Escape qw(uri_escape);

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

    my $key = params("route")->{key};
    my $form = LibreCat::Form->load( $key, "en" ) or pass;

    template "forms/".uri_escape($key),{ form => $form };

};

post "/forms/:key" => sub {

    my $key = params("route")->{key};
    my $form = LibreCat::Form->load( $key, "en" ) or pass;

    my $params = params("body");
    my $result = $form->run( params => $params );

    template "forms/".uri_escape($key),{ form => $result };

};

1;
