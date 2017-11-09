package SingClearly::Controller::Checker;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::UserAgent;
use Mojo::File;

sub check {
    my $c = shift;

    my $otitle = $c->param('title');
    my $oartist = $c->param('artist');

    my $title = lc($otitle);
    my $artist = lc($oartist);

    $title =~ s/ /-/g;
    $title =~ s/'/a/g;
    $artist =~ s/ /-/g;

    $c->app->log->info("Request for title '$title' and artist '$artist'");

    my $ua = Mojo::UserAgent->new();

    my $link = "http://www.metrolyrics.com/$title-lyrics-$artist.html";
    my $res = $ua->get($link)->result;

    if ($res->is_success) {
	my $text = $res->dom->find('.verse')->map('text')->join("\n");
	my $blacklist = Mojo::File->new($c->config->{blacklist_path})->slurp();

	my @phrases = ();
	for my $line (split /\n/, $blacklist) {
	    if ($text =~ /$line/i) {
		push @phrases, $line;
	    }
	}

	$c->render(json => { lyrics => $text,
			     phrase_count => scalar @phrases,
			     phrases => \@phrases,
			     link => $link,
			     title => $otitle,
			     artist => $oartist });
    }
    else {
	$c->render(text => "could not find song",
		   status => 400);
    }
}

sub add_to_blacklist {
    my $c = shift;

    my $phrase = $c->param('phrase');
    $c->app->log->info("Adding phrase '$phrase' to blacklist.");

    return unless $phrase;

    my $fh = Mojo::File->new($c->config->{blacklist_path})->open('a');
    print $fh "$phrase\n";
    $c->render(text => "done",
	       status => 200);
}

1;
