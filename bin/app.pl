#!/usr/bin/env perl
use Catmandu::Sane;
use Catmandu -load => ["."];
use Catmandu::Util qw(:is);
use Dancer;
use Upload;
use App;
use NotFound;
use Plack::Builder;

my $app = sub {
    Dancer->dance(Dancer::Request->new(env => $_[0]));
};

builder {
    enable 'Session';
    mount '/' => $app;
};
