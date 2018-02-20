package SingClearly::Controller::Checker;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::UserAgent;
use Mojo::File;

sub check {
    my $c = shift;

    my $otitle = $c->param('title');
    my $oartist = $c->param('artist');

    my ($status, $data) = $c->check_song($otitle, $oartist);
    if ($status eq 'ok') {
	$c->render(json => $data);
    }
    else {
	$c->render(text => 'error',
		   status => 400);
    }
}

sub check_list {
    my $c = shift;

    my $share_link = $c->param('share_link');

    $c->app->log->debug("Share link: '$share_link'");

    my $ua = Mojo::UserAgent->new();

    my $res = $ua->get($share_link)->result;

    $c->app->log->info("downloading shared list: $share_link");

    my @songs = ();

    if ($res->is_success) {
	my @titles = @{$res->dom->find('.track-name')->map('text')};
	my @artists = @{$res->dom->find('.artists-albums > a:first-child')->map('text')};

	foreach (@titles) {
	    my $blob = { title => $_, artist => shift @artists };
	    $c->app->log->debug("Blob:");
	    $c->app->log->debug($c->app->dumper($blob));
	    push @songs, $blob;
	}

	$c->app->log->info("got following from list:");
	$c->app->log->info($c->app->dumper(\@songs));
	my @results = map { my ($status, $data) = $c->check_song($_->{title}, $_->{artist}); $status eq 'ok' ? $data : {title => $_->{title}, artist => $_->{artist}}; } @songs;
	$c->render(json => \@results);
    }
    else {
	$c->render(text => "error retrieving list",
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
