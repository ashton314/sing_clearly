package SingClearly;
use Mojo::Base 'Mojolicious';

use Mojo::File;
use Mojo::UserAgent;
use List::Util qw(uniq);

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer') if $config->{perldoc};

  $self->log->info("Fetching vulgarities to blacklist...");

  init_blacklist($self, $self->config->{blacklist_path});

  $self->log->info("Fetching...done.");

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  $r->get('/checker')->to('UI#checker');

  $r->get('/check-song')->to('Checker#check');
  $r->post('/blacklist')->to('Checker#add_to_blacklist');
}

sub init_blacklist {
    my $c = shift;
    my $file = shift;

    my @phrases = split /\n/, Mojo::File->new($file)->slurp();

    my $url = "https://www.frontgatemedia.com/new/wp-content/uploads/2014/03/Terms-to-Block.csv";
    my $ua = Mojo::UserAgent->new();
    my $res = $ua->get($url)->result;

    if ($res->is_success) {
	my $text = $res->body;
	for my $line (split /\n/, $text) {
	    next unless $line =~ /^,"(\w+),"\s*$/;
	    push @phrases, $1;
	}

	Mojo::File->new($file)->spurt((join "\n", uniq(@phrases)) . "\n");
    }
    else {
	$c->log->error("ERROR: couldn't pull list of bad words");
    }
}

1;
