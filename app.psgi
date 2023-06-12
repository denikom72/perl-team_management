# Your Perl code implementing the MVC pattern without a framework, using PSGI, DTOs, and DAOs.

# Import required modules
use strict;
use warnings;
use CGI;
use CGI::Session;
use Template;
use DBI;
use Digest::SHA qw(sha256_hex);
use Plack::Response;
use Plack::Builder;
use Plack::Middleware::Header;
use Text::Trim;
use Plack::Loader;
use Plack::Request;
use Plack::Session;
#use Devel::hdb;
use Data::Dumper;

# Enable debugging
#Devel::hdb->new;

my ( $session, $req, $response, $vars, $tpl, $template_context );


# Set up the CGI environment
my $cgi = CGI->new();

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

# Generate a CSRF token
sub generate_csrf_token {
    return sha256_hex(rand() . time . rand());
}

# Check if the CSRF token is valid
sub check_csrf_token {
    my $cgi = shift;
    my $session = CGI::Session->load();
    my $csrf_token = $session->param('csrf_token');
    my $submitted_token = $cgi->param('csrf_token');
    return $csrf_token && $submitted_token && $csrf_token eq $submitted_token;
}

# Show the login form
my $show_login = sub{
    $vars = {
    	login_cont => undef 
    };
	    
    $tpl = 'login.tmpl';
};

# Handle the login request
my $handle_login = sub{
    #my $req = shift;
      
    print STDERR "\n\n________**********_________________IN__HANDLE_LOGIN___________\n\n";
    print STDERR Dumper $req->parameters;

    print STDERR $req->param('password');
    print STDERR $req->param('username');
    
    #my $username = 'admin'; 
    #my $password = 'password'; 
    my $username = $req->param('username');
    my $password = $req->param('password');
    #my $hashed_password = sha256_hex($password);
    my $hashed_password = $password;

    # Perform the login validation
    my $stmt = $dbh->prepare('SELECT id FROM users WHERE username = ? AND password = ?');
    $stmt->execute($username, $hashed_password);
    my ($user_id) = $stmt->fetchrow_array();
    $stmt->finish();
    if ($user_id) {
	print STDERR "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL " . $user_id;
	#my $session = Plack::Session->new() or die Plack::Session->errstr;
	#my $session = $req->session() or die ( "session error");
	print STDERR Dumper $session;
	print STDERR "99999999999999999999999OOOOOOOOOOOOOLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL " . $user_id;
        $session->{user_id} = "1";

        $session->{csrf_token} = generate_csrf_token();
	print STDERR "ZZZZZZZZZZZZZZZZZZZLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL " . Dumper $session;
	
	#my $res = Plack::Response->new();
	#$response->redirect('/testlogin');

	#return $response->finalize;
    } else {
	#print $cgi->header();
        print "Invalid username or password.";
    }
};

# Show the admin panel
my $show_admin_panel = sub{
    my $user_id = CGI::Session->load()->param('user_id');
    my $stmt = $dbh->prepare('SELECT username FROM users WHERE id = ?');
    $stmt->execute($user_id);
    my ($username) = $stmt->fetchrow_array();
    $stmt->finish();

    # Pass the username to the template
    $vars = { username => $username };
    $tpl = 'admin_panel.tmpl';
};

# Show the teams
my $show_teams = sub{
    # Fetch teams from the database
    my $stmt = $dbh->prepare('SELECT id, name FROM teams');
    $stmt->execute();

    my @teams;
    while (my ($id, $name) = $stmt->fetchrow_array()) {
        push @teams, TeamDTO->new($id, $name);
    }
    $stmt->finish();

    # Pass the teams to the template
    $vars = { teams => \@teams };
    $tpl = 'teams.tmpl';
};

# Show team members
my $show_team_members = sub{
    my ($team_id) = @_;
    my $stmt = $dbh->prepare('SELECT id, name FROM team_members WHERE team_id = ?');
    $stmt->execute($team_id);

    my @team_members;
    while (my ($id, $name) = $stmt->fetchrow_array()) {
        push @team_members, TeamMemberDTO->new($id, $team_id, $name);
    }
    $stmt->finish();

    $vars = { team_members => \@team_members };
    $tpl = 'team_members.tmpl';
};

# Show team roles
my $show_team_roles = sub{
    my ($team_id) = @_;
    my $stmt = $dbh->prepare('SELECT id, name FROM team_roles WHERE team_id = ?');
    $stmt->execute($team_id);

    my @team_roles;
    while (my ($id, $name) = $stmt->fetchrow_array()) {
        push @team_roles, TeamRoleDTO->new($id, $team_id, $name);
    }
    $stmt->finish();

    $vars = { team_roles => \@team_roles };
    $tpl = 'team_roles.tmpl';
};

# Handle team creation
my $handle_create_team = sub{
    my $name = $cgi->param('name');

    # Insert the team into the database
    my $stmt = $dbh->prepare('INSERT INTO teams (name) VALUES (?)');
    $stmt->execute($name);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=teams');
};

# Handle team deletion
my $handle_delete_team = sub{
    my $team_id = $cgi->param('team_id');

    # Delete the team from the database
    my $stmt = $dbh->prepare('DELETE FROM teams WHERE id = ?');
    $stmt->execute($team_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=teams');
};

# Handle team update
my $handle_update_team = sub{
    my $team_id = $cgi->param('team_id');
    my $name = $cgi->param('name');

    # Update the team in the database
    my $stmt = $dbh->prepare('UPDATE teams SET name = ? WHERE id = ?');
    $stmt->execute($name, $team_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=teams');
};

# Handle team member creation
my $handle_create_team_member = sub{
    my $team_id = $cgi->param('team_id');
    my $name = $cgi->param('name');

    # Insert the team member into the database
    my $stmt = $dbh->prepare('INSERT INTO team_members (team_id, name) VALUES (?, ?)');
    $stmt->execute($team_id, $name);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_members&team_id=' . $team_id);
};

# Handle team member deletion
my $handle_delete_team_member = sub{
    my $team_member_id = $cgi->param('team_member_id');
    my $team_id = $cgi->param('team_id');

    # Delete the team member from the database
    my $stmt = $dbh->prepare('DELETE FROM team_members WHERE id = ?');
    $stmt->execute($team_member_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_members&team_id=' . $team_id);
};

# Handle team member update
my $handle_update_team_member = sub{
    my $team_member_id = $cgi->param('team_member_id');
    my $team_id = $cgi->param('team_id');
    my $name = $cgi->param('name');

    # Update the team member in the database
    my $stmt = $dbh->prepare('UPDATE team_members SET name = ? WHERE id = ?');
    $stmt->execute($name, $team_member_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_members&team_id=' . $team_id);
};

# Handle team role creation
my $handle_create_team_role = sub{
    my $team_id = $cgi->param('team_id');
    my $name = $cgi->param('name');

    # Insert the team role into the database
    my $stmt = $dbh->prepare('INSERT INTO team_roles (team_id, name) VALUES (?, ?)');
    $stmt->execute($team_id, $name);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_roles&team_id=' . $team_id);
};

# Handle team role deletion
my $handle_delete_team_role = sub{
    my $team_role_id = $cgi->param('team_role_id');
    my $team_id = $cgi->param('team_id');

    # Delete the team role from the database
    my $stmt = $dbh->prepare('DELETE FROM team_roles WHERE id = ?');
    $stmt->execute($team_role_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_roles&team_id=' . $team_id);
};

# Handle team role update
my $handle_update_team_role = sub{
    my $team_role_id = $cgi->param('team_role_id');
    my $team_id = $cgi->param('team_id');
    my $name = $cgi->param('name');

    # Update the team role in the database
    my $stmt = $dbh->prepare('UPDATE team_roles SET name = ? WHERE id = ?');
    $stmt->execute($name, $team_role_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_roles&team_id=' . $team_id);
};

# Main PSGI application handler
sub app {
    my $env = shift;
    
    $response = Plack::Response->new(200);
    
    print STDERR "OOOOOO__________________________________________\n\n";
    #print STDERR Dumper($env);   
    
    # TODO:Parse the request parameters
    
    $req = Plack::Request->new($env);
    #my $res = Plack::Response->new();

    print STDERR Dumper $req->parameters;

    print STDERR $req->param('password');
    print STDERR $req->param('username');
    
    $session = $req->session; # or die "session error"; 
    
    #$cgi->parse_params($env->{QUERY_STRING});

    my $path_info = $env->{PATH_INFO};

    my $request_method = $env->{REQUEST_METHOD};
    
#    if ($path_info eq '/login') {
#        
#	if ( $request_method eq 'POST') {
#            
#	     handle_login();
#        } else {
#	     show_login();
#        }
#    } 
    #elsif ($path_info eq '/admin_panel') {
    if ($path_info eq '/admin_panel') {
        if (check_csrf_token($cgi)) {
            if ($cgi->param('action') eq 'teams') {
                show_teams();
            } elsif ($cgi->param('action') eq 'team_members') {
                show_team_members($cgi->param('team_id'));
            } elsif ($cgi->param('action') eq 'team_roles') {
                show_team_roles($cgi->param('team_id'));
            } else {
                show_admin_panel();
            }
        } else {
            print $cgi->header();
            print "Invalid CSRF token.";
        }
    } elsif ($path_info eq '/create_team') {
        if (check_csrf_token($cgi)) {
            handle_create_team();
        } else {
            print $cgi->header();
            print "Invalid CSRF token.";
        }
    } elsif ($path_info eq '/delete_team') {
        if (check_csrf_token($cgi)) {
            handle_delete_team();
        } else {
            print $cgi->header();
            print "Invalid CSRF token.";
        }
    } elsif ($path_info eq '/update_team') {
        if (check_csrf_token($cgi)) {
            handle_update_team();
        } else {
            print $cgi->header();
            print "Invalid CSRF token.";
        }
    } elsif ($path_info eq '/create_team_member') {
        if (check_csrf_token($cgi)) {
            handle_create_team_member();
        } else {
            print $cgi->header();
            print "Invalid CSRF token.";
        }
    } elsif ($path_info eq '/delete_team_member') {
        if (check_csrf_token($cgi)) {
            handle_delete_team_member();
        } else {
            print $cgi->header();
            print "Invalid CSRF token.";
        }
    } elsif ($path_info eq '/update_team_member') {
        if (check_csrf_token($cgi)) {
            handle_update_team_member();
        } else {
            print $cgi->header();
            print "Invalid CSRF token.";
        }
    } elsif ($path_info eq '/create_team_role') {
        if (check_csrf_token($cgi)) {
            handle_create_team_role();
        } else {
            print $cgi->header();
            print "Invalid CSRF token.";
        }
    } elsif ($path_info eq '/delete_team_role') {
        if (check_csrf_token($cgi)) {
            handle_delete_team_role();
        } else {
            print $cgi->header();
            print "Invalid CSRF token.";
        }
    } elsif ($path_info eq '/update_team_role') {
        if (check_csrf_token($cgi)) {
            handle_update_team_role();
        } else {
            print $cgi->header();
            print "Invalid CSRF token.";
        }
    } else {
        # Invalid URL
        print $cgi->header();
        print "Invalid URL.";
    }
    
    my $html = '';

    $template_context = $template->context;
    unless ( $template_context->template($tpl)->_is_cached ) { 
         $template->process($tpl, { vars => $vars }, \$html) or die " >>>>>>>>>>>>>>>>>>>>>>> Template processing failed: $template::ERROR";
    }

    # Create the Plack response with the HTML content
    
    $response->content_type('text/html');
    
    $response->body($html);

    return $response->finalize;

    #return [200, ['Content-Type' => 'text/html'], ['']];
}

# Start the PSGI application
my $app = sub { app(@_) };

builder {
     enable 'Session', store => 'File'; #default uses Plack::Session::State::Cookie
     #enable 'Header',
     #  set_headers => {
     #      'Cache-Control' => 'no-cache, no-store, must-revalidate',
     #      'Pragma' => 'no-cache',
     #      'Expires' => '0',
     #  };
     mount "/" => $app;
     mount "/login" => $show_login;
};

# Export the PSGI application

#return $app;

