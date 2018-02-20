package SingClearly::Controller::UI;
use Mojo::Base 'Mojolicious::Controller';

sub checker {
    my $c = shift;
    $c->render(template => 'ui/checker');
}

sub list_checker {
    my $c = shift;
    $c->render(template => 'ui/list_checker');
}

1;
