use strict;
use warnings;
use Plack::Request;
use Plack::Response;
use Plack::Builder;
use Digest::SHA qw(sha256_hex);
use Data::Dumper;
use Template;
use DBI;

use lib "models";
use User;

my ( $tpl, $vars );

# Configure the database connection
my $db_file = 'team_management.db';
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file") or die "Couldn't connect to database: $DBI::errstr";

# Set up the template engine
my $template = Template->new({
    INCLUDE_PATH => './views',
    INTERPOLATE  => 1,
    CACHE_SIZE => 64 
}) or die "Couldn't initialize template: $Template::ERROR";

sub set_vars {
	$vars = shift;
}


my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    
    my $session = $req->session;
    my $res = Plack::Response->new(200);
    $res->content_type('text/html');
    
    my $link = $session->{user}
            ? q{ <a href="/logout">logout</a>}
            : q{ <a href="/loginpage">login</a>}
            ;
    
    $res->body(["Session user:", $session->{user}, "<br>$link"]);
    
    return $res->finalize;
};


my $loginpage = sub {
    
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $session = $req->session;

    #$session->{user} = "some";
    $session->{csrf_token} = generate_csrf_token();
    #how to set here the session-state-cookie expiration?

    my $res = Plack::Response->new(200);
    $res->content_type('text/html');
    
    my $html = '';
    
    my $vars = { login_count => undef };
    
    my $tpl = "login.tmpl";
    
    #$tpl = "admin_panel.tmpl";

    my $template_context = $template->context;
    unless ( $template_context->template($tpl)->_is_cached ) { 
         $template->process($tpl, { vars => $vars }, \$html) or die "Template processing failed: $template::ERROR";
    }

    $res->body($html);
    #$res->redirect("/", 302);
    return $res->finalize;
};

my $login = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $session = $req->session;

    print STDERR Dumper $req->parameters;
    
    #$session->{user} = $req->params('name');
    #$session->{password} = $req->params('password');
    
    $session->{csrf_token} = generate_csrf_token();
    #how to set here the session-state-cookie expiration?

    my $user = User->new($req->param('username'), $req->param('password'));
    
    my $res = Plack::Response->new(200);
    $res->content_type('text/html');
    
    my $html = '';
    
    $vars = { usermail => $user->get_email(), content => "<a href='/logout'>logout</a>" };
    #$tpl = "login.tmpl";
    $tpl = "admin_panel.tmpl";
    

    my $template_context = $template->context;
    unless ( $template_context->template($tpl)->_is_cached ) { 
         $template->process($tpl, { vars => $vars }, \$html) or die " >>>>>>>>>>>>>>>>>>>>>>> Template processing failed: $template::ERROR";
    }

    $res->body($html);
    #$res->redirect("/", 302);
    return $res->finalize;
};


my $logout = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $session = $req->session;
    delete $session->{user};
    my $res = Plack::Response->new();
    $res->redirect("/", 302);
    return $res->finalize;
};


# Generate a CSRF token
sub generate_csrf_token {
    return sha256_hex(rand() . time . rand());
}

# Check if the CSRF token is valid
sub check_csrf_token {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $session = $req->session;
    my $csrf_token = $session->{csrf_token};
    my $submitted_token = $session->{csrf_token};
    return $csrf_token && $submitted_token && $csrf_token eq $submitted_token;
}

builder {
    enable 'Session', store => 'File';
    mount "/" => $loginpage;
    mount "/login" => $login;
    mount "/logout" => $logout;
    mount "/favicon.ico" => sub { return [ 404, ['Content-Type' => 'text/html'], [ '404 Not Found' ] ] };
    mount "/assets/style.css" => sub { return [ 200, ['Content-Type' => 'text/css'], [ '404 Not Found' ] ] };
    mount "/" => $app;
};




