use strict;
use warnings;
use Plack::Request;
use Plack::Response;
use Plack::Builder;
use Digest::SHA qw(sha256_hex);
use Data::Dumper;
use Template;
use DBI;


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

    my $res = Plack::Response->new(200);
    $res->content_type('text/html');
    
    my $html = '';
    
    $vars = { username => $session->{user} };
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


package User;

ipackage User;

use strict;
use warnings;

=head1 NAME

User - Represents a user with email, password, and id attributes

=head1 SYNOPSIS

  use User;

  my $user = User->new('user@example.com', 'password123', 1);

  my $email = $user->get_email;
  my $password = $user->get_password;
  my $id = $user->get_id;

  $user->set_email('newuser@example.com');
  $user->set_password('newpassword');
  $user->set_id(2);

=head1 DESCRIPTION

The User module represents a user with email, password, and id attributes. It provides methods for accessing and modifying these attributes.

=head1 METHODS

=cut

sub new {
    my ($class, $email, $password, $id) = @_;
    my $self = {
        email    => $email,
        password => $password,
        id       => $id,
    };
    bless $self, $class;
    return $self;
}

=head2 get_email

Returns the user's email address.

=cut

sub get_email {
    my ($self) = @_;
    return $self->{email};
}

=head2 set_email

Sets the user's email address. Performs a plausibility check using regex.

=cut

sub set_email {
    my ($self, $email) = @_;

    # Plausibility check using regex
    if ($email =~ /^[^\s@]+@[^\s@]+\.[^\s@]+$/) {
        $self->{email} = $email;
    } else {
        die "Invalid email format";
    }
}

=head2 get_password

Returns the user's password.

=cut

sub get_password {
    my ($self) = @_;
    return $self->{password};
}

=head2 set_password

Sets the user's password.

=cut

sub set_password {
    my ($self, $password) = @_;
    $self->{password} = $password;
}

=head2 get_id

Returns the user's ID.

=cut

sub get_id {
    my ($self) = @_;
    return $self->{id};
}

=head2 set_id

Sets the user's ID.

=cut

sub set_id {
    my ($self, $id) = @_;
    $self->{id} = $id;
}

1;



