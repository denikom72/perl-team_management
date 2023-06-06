# Your Perl code implementing the MVC pattern without a framework, using PSGI, DTOs, and DAOs.

# Import required modules
use strict;
use warnings;
use CGI;
use CGI::Session;
use Template;
use DBI;
use Digest::SHA qw(sha256_hex);

# Set up the CGI environment
my $cgi = CGI->new();

# Configure the database connection
my $db_file = 'database.db';
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file") or die "Couldn't connect to database: $DBI::errstr";

# Set up the template engine
my $template = Template->new({
    INCLUDE_PATH => 'templates',
    INTERPOLATE  => 1,
}) or die "Couldn't initialize template: $Template::ERROR";

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
sub show_login {
    $template->process('login.tmpl') or die "Template processing failed: $template::ERROR";
}

# Handle the login request
sub handle_login {
    my $username = $cgi->param('username');
    my $password = $cgi->param('password');
    my $hashed_password = sha256_hex($password);

    # Perform the login validation
    my $stmt = $dbh->prepare('SELECT id FROM users WHERE username = ? AND password = ?');
    $stmt->execute($username, $hashed_password);
    my ($user_id) = $stmt->fetchrow_array();
    $stmt->finish();

    if ($user_id) {
        my $session = CGI::Session->new() or die CGI::Session->errstr;
        $session->param('user_id', $user_id);
        $session->param('csrf_token', generate_csrf_token());
        print $cgi->redirect(-url => '/admin_panel');
    } else {
        print $cgi->header();
        print "Invalid username or password.";
    }
}

# Show the admin panel
sub show_admin_panel {
    my $user_id = CGI::Session->load()->param('user_id');
    my $stmt = $dbh->prepare('SELECT username FROM users WHERE id = ?');
    $stmt->execute($user_id);
    my ($username) = $stmt->fetchrow_array();
    $stmt->finish();

    # Pass the username to the template
    my $vars = { username => $username };
    $template->process('admin_panel.tmpl', $vars) or die "Template processing failed: $template::ERROR";
}

# Show the teams
sub show_teams {
    # Fetch teams from the database
    my $stmt = $dbh->prepare('SELECT id, name FROM teams');
    $stmt->execute();

    my @teams;
    while (my ($id, $name) = $stmt->fetchrow_array()) {
        push @teams, TeamDTO->new($id, $name);
    }
    $stmt->finish();

    # Pass the teams to the template
    my $vars = { teams => \@teams };
    $template->process('teams.tmpl', $vars) or die "Template processing failed: $template::ERROR";
}

# Show team members
sub show_team_members {
    my ($team_id) = @_;
    my $stmt = $dbh->prepare('SELECT id, name FROM team_members WHERE team_id = ?');
    $stmt->execute($team_id);

    my @team_members;
    while (my ($id, $name) = $stmt->fetchrow_array()) {
        push @team_members, TeamMemberDTO->new($id, $team_id, $name);
    }
    $stmt->finish();

    my $vars = { team_members => \@team_members };
    $template->process('team_members.tmpl', $vars) or die "Template processing failed: $template::ERROR";
}

# Show team roles
sub show_team_roles {
    my ($team_id) = @_;
    my $stmt = $dbh->prepare('SELECT id, name FROM team_roles WHERE team_id = ?');
    $stmt->execute($team_id);

    my @team_roles;
    while (my ($id, $name) = $stmt->fetchrow_array()) {
        push @team_roles, TeamRoleDTO->new($id, $team_id, $name);
    }
    $stmt->finish();

    my $vars = { team_roles => \@team_roles };
    $template->process('team_roles.tmpl', $vars) or die "Template processing failed: $template::ERROR";
}

# Handle team creation
sub handle_create_team {
    my $name = $cgi->param('name');

    # Insert the team into the database
    my $stmt = $dbh->prepare('INSERT INTO teams (name) VALUES (?)');
    $stmt->execute($name);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=teams');
}

# Handle team deletion
sub handle_delete_team {
    my $team_id = $cgi->param('team_id');

    # Delete the team from the database
    my $stmt = $dbh->prepare('DELETE FROM teams WHERE id = ?');
    $stmt->execute($team_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=teams');
}

# Handle team update
sub handle_update_team {
    my $team_id = $cgi->param('team_id');
    my $name = $cgi->param('name');

    # Update the team in the database
    my $stmt = $dbh->prepare('UPDATE teams SET name = ? WHERE id = ?');
    $stmt->execute($name, $team_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=teams');
}

# Handle team member creation
sub handle_create_team_member {
    my $team_id = $cgi->param('team_id');
    my $name = $cgi->param('name');

    # Insert the team member into the database
    my $stmt = $dbh->prepare('INSERT INTO team_members (team_id, name) VALUES (?, ?)');
    $stmt->execute($team_id, $name);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_members&team_id=' . $team_id);
}

# Handle team member deletion
sub handle_delete_team_member {
    my $team_member_id = $cgi->param('team_member_id');
    my $team_id = $cgi->param('team_id');

    # Delete the team member from the database
    my $stmt = $dbh->prepare('DELETE FROM team_members WHERE id = ?');
    $stmt->execute($team_member_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_members&team_id=' . $team_id);
}

# Handle team member update
sub handle_update_team_member {
    my $team_member_id = $cgi->param('team_member_id');
    my $team_id = $cgi->param('team_id');
    my $name = $cgi->param('name');

    # Update the team member in the database
    my $stmt = $dbh->prepare('UPDATE team_members SET name = ? WHERE id = ?');
    $stmt->execute($name, $team_member_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_members&team_id=' . $team_id);
}

# Handle team role creation
sub handle_create_team_role {
    my $team_id = $cgi->param('team_id');
    my $name = $cgi->param('name');

    # Insert the team role into the database
    my $stmt = $dbh->prepare('INSERT INTO team_roles (team_id, name) VALUES (?, ?)');
    $stmt->execute($team_id, $name);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_roles&team_id=' . $team_id);
}

# Handle team role deletion
sub handle_delete_team_role {
    my $team_role_id = $cgi->param('team_role_id');
    my $team_id = $cgi->param('team_id');

    # Delete the team role from the database
    my $stmt = $dbh->prepare('DELETE FROM team_roles WHERE id = ?');
    $stmt->execute($team_role_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_roles&team_id=' . $team_id);
}

# Handle team role update
sub handle_update_team_role {
    my $team_role_id = $cgi->param('team_role_id');
    my $team_id = $cgi->param('team_id');
    my $name = $cgi->param('name');

    # Update the team role in the database
    my $stmt = $dbh->prepare('UPDATE team_roles SET name = ? WHERE id = ?');
    $stmt->execute($name, $team_role_id);
    $stmt->finish();

    print $cgi->redirect(-url => '/admin_panel?action=team_roles&team_id=' . $team_id);
}

# Main PSGI application handler
sub app {
    my $env = shift;

    # Parse the request parameters
    $cgi->parse_params($env->{QUERY_STRING});

    my $path_info = $env->{PATH_INFO};

    if ($path_info eq '/login') {
        if ($cgi->request_method eq 'POST') {
            handle_login();
        } else {
            show_login();
        }
    } elsif ($path_info eq '/admin_panel') {
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

    return [200, ['Content-Type' => 'text/html'], ['']];
}

# Start the PSGI application
my $app = sub { app(@_) };

# Export the PSGI application
return $app;

