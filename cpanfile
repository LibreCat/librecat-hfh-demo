requires "perl",">=5.10.1";

requires 'Carp','0';
requires 'Moo','0';
requires 'URI::Escape','0';

#See https://github.com/gshank/html-formhandler/pull/110
#See http://cpansearch.perl.org/src/GSHANK/HTML-FormHandler-0.40065/Changes
requires 'HTML::FormHandler','<0.40065';
requires 'Plack','1.0044';
requires 'Plack::Middleware::Session','==0.25';
requires 'Plack::Handler::Starman','0';
requires 'Dancer','0';
requires 'Dancer::Session::PSGI','0';
requires 'Template','2.27';
requires 'Catmandu','1.09';
requires 'LWP::Protocol::https';
requires 'Template::Plugin::JSON::Escape';
requires 'Clone';
requires 'Business::ISBN';
requires 'Business::ISSN';
requires 'Catmandu::FileStore','1.10';
requires 'Locale::Maketext::Lexicon';
requires 'MIME::Types';
