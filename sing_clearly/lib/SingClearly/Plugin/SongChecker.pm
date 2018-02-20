package SingClearly::Plugin::SongChecker;
use base 'Mojolicious::Plugin';

sub register {
    my ($self, $app, $conf) = @_;

    $app->helper(check_song => sub {
        my ($c, $otitle, $oartist) = @_;

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
		if ($text =~ /\b$line\b/i) {
		    push @phrases, $line;
		}
	    }

	    return ('ok', { lyrics => $text,
			    phrase_count => scalar @phrases,
			    phrases => \@phrases,
			    link => $link,
			    text => $text,
			    title => $otitle,
			    artist => $oartist });
	}
	else {
	    return ('error', '');
	}

    });

}

1;
