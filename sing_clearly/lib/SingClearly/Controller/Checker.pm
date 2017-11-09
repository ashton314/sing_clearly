package SingClearly::Controller::Checker;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::UserAgent;

sub check {
    my $c = shift;

    my $title = lc($c->param('title'));
    my $artist = lc($c->param('artist'));

    $title =~ s/ /-/g;
    $artist =~ s/ /-/g;

    $c->app->log->info("Request for title '$title' and artist '$artist'");

    my $ua = Mojo::UserAgent->new();

    my $res = $ua->get("http://www.metrolyrics.com/$title-lyrics-$artist.html")->result;

    if ($res->is_success) {
	my $text = $res->dom->find('.verse')->map('text')->join("\n");

	$c->render(json => { lyrics => $text,
			     phrase_count => 0,
			     phrases => [1, 2, 3],
			     title => $title,
			     artist => $artist });
    }
    else {
	$c->render(text => "could not find song",
		   status => 400);
    }
}

sub add_to_blacklist {
    my $c = shift;

    ...;
}

1;
