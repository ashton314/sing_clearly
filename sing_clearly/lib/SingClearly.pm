package SingClearly;
use Mojo::Base 'Mojolicious';

use Mojo::File;
use Mojo::UserAgent;
use List::Util qw(uniq);

# This method will run once at server start
sub startup {
  my $app = shift;

  # Load configuration from hash returned by "my_app.conf"
  my $config = $app->plugin('Config');

  push @{$app->plugins->namespaces}, 'SingClearly::Plugin';
  $app->plugin(SongChecker => $config);

  # Documentation browser under "/perldoc"
  $app->plugin('PODRenderer') if $config->{perldoc};

  $app->log->info("Fetching vulgarities to blacklist...");

  init_blacklist($app, $app->config->{blacklist_path});

  $app->log->info("Fetching...done.");

  # Router
  my $r = $app->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  $r->get('/checker')->to('UI#checker');

  $r->get('/list-checker')->to('UI#list_checker');


  $r->get('/check-song')->to('Checker#check');
  $r->get('/check-listing')->to('Checker#check_list');
  $r->post('/blacklist')->to('Checker#add_to_blacklist');
}

sub init_blacklist {
    my $c = shift;
    my $file = shift;

    my $path = Mojo::File->new($file);

    unless (-e $path) {
	$path->spurt('');
    }

    my @phrases = split /\n/, $path->slurp();

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
