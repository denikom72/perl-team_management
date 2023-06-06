# this is if you run mod_perl or fastcgi, not psg
#
# Main Application

use strict;
use warnings;
use CGI;
use CGI::Session;
use Digest::SHA qw(sha256_hex);
use Template;
use DBI;

# Database configuration
my $db_file = 'admin_panel.db';
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","") or die "Could not connect to database: $DBI::errstr";

# Initialize CGI object
my $cgi = CGI->new;

# Check CSRF token
sub check_csrf_token {
    my ($cgi) = @_;
    my $csrf_token = $cgi->param('csrf_token');
    my $session = CGI::Session->load() or die CGI::Session->errstr;
    my $stored_token = $session->param('csrf_token');
    return $csrf_token eq $stored_token;
}

# Generate CSRF token
sub generate_csrf_token {
    my $session = CGI::Session->load() or die CGI::Session->errstr;
    my $csrf_token = sha256_hex(time . rand());
    $session->param('csrf_token', $csrf_token);
    return $csrf_token;
}

# Login
sub login {
    my ($username, $password) = @_;
    my $hashed_password = sha256_hex($password);
    my $sth = $dbh->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
    $sth->execute($username, $hashed_password);
    my $user = $sth->fetchrow_hashref;
    $sth->finish;
    return $user;
}

# Create team
sub create_team {
    my ($team_name) = @_;
    my $sth = $dbh->prepare("INSERT INTO teams (name) VALUES (?)");
    $sth->execute($team_name);
    $sth->finish;
}

# Delete team
sub delete_team {
    my ($team_id) = @_;
    my $sth = $dbh->prepare("DELETE FROM teams WHERE id = ?");
    $sth->execute($team_id);
    $sth->finish;
}

# Update team
sub update_team {
    my ($team_id, $team_name) = @_;
    my $sth = $dbh->prepare("UPDATE teams SET name = ? WHERE id = ?");
    $sth->execute($team_name, $team_id);
    $sth->finish;
}

# Create team member
sub create_team_member {
    my ($team_id, $member_name) = @_;
    my $sth = $dbh->prepare("INSERT INTO team_members (team_id, name) VALUES (?, ?)");
    $sth->execute($team_id, $member_name);
    $sth->finish;
}

# Delete team member
sub delete_team_member {
    my ($team_member_id) = @_;
    my $sth = $dbh->prepare("DELETE FROM team_members WHERE id = ?");
    $sth->execute($team_member_id);
    $sth->finish;
}

# Update team member
sub update_team_member {
    my ($team_member_id, $member_name) = @_;
    my $sth = $dbh->prepare("UPDATE team_members SET name = ? WHERE id = ?");
    $sth->execute($member_name, $team_member_id);
    $sth->finish;
}

# Create team role
sub create_team_role {
    my ($team_id, $role_name) = @_;
    my $sth = $dbh->prepare("INSERT INTO team_roles (team_id, name) VALUES (?, ?)");
    $sth->execute($team_id, $role_name);
    $sth->finish;
}

# Delete team role
sub delete_team_role {
    my ($team_role_id) = @_;
    my $sth = $dbh->prepare("DELETE FROM team_roles WHERE id = ?");
    $sth->execute($team_role_id);
    $sth->finish;
}

# Update team role
sub update_team_role {
    my ($team_role_id, $role_name) = @_;
    my $sth = $dbh->prepare("UPDATE team_roles SET name = ? WHERE id = ?");
    $sth->execute($role_name, $team_role_id);
    $sth->finish;
}

# Render template
sub render_template {
    my ($template_file, $vars) = @_;
    my $template = Template->new({
        INCLUDE_PATH => 'views',
        INTERPOLATE  => 1,
        ENCODING     => 'utf8',
        PRE_CHOMP    => 1,
        POST_CHOMP   => 1,
    }) or die "Failed to initialize Template: $Template::ERROR\n";
    $template->process($template_file, $vars) or die "Template processing failed: " . $template->error() . "\n";
}

# Login page
sub show_login {
    render_template('login.tmpl', {});
}

# Admin panel page
sub show_admin_panel {
    my ($user) = @_;
    render_template('admin_panel.tmpl', { user => $user });
}

# Teams page
sub show_teams {
    my ($user) = @_;
    my $sth = $dbh->prepare("SELECT * FROM teams");
    $sth->execute();
    my @teams;
    while (my $row = $sth->fetchrow_hashref) {
        push @teams, $row;
    }
    $sth->finish;
    render_template('teams.tmpl', { user => $user, teams => \@teams });
}

# Team members page
sub show_team_members {
    my ($user, $team_id) = @_;
    my $sth = $dbh->prepare("SELECT * FROM team_members WHERE team_id = ?");
    $sth->execute($team_id);
    my @team_members;
    while (my $row = $sth->fetchrow_hashref) {
        push @team_members, $row;
    }
    $sth->finish;
    render_template('team_members.tmpl', { user => $user, team_id => $team_id, team_members => \@team_members });
}

# Team roles page
sub show_team_roles {
    my ($user, $team_id) = @_;
    my $sth = $dbh->prepare("SELECT * FROM team_roles WHERE team_id = ?");
    $sth->execute($team_id);
    my @team_roles;
    while (my $row = $sth->fetchrow_hashref) {
        push @team_roles, $row;
    }
    $sth->finish;
    render_template('team_roles.tmpl', { user => $user, team_id => $team_id, team_roles => \@team_roles });
}

# Handle login request
sub handle_login {
    my $username = $cgi->param('username');
    my $password = $cgi->param('password');
    my $user = login($username, $password);
    if ($user) {
        my $session = CGI::Session->new() or die CGI::Session->errstr;
        $session->param('user', $user);
        $session->param('csrf_token', generate_csrf_token());
        print $cgi->redirect(-url => '/admin_panel', -cookie => $session->cookie);
    } else {
        print $cgi->header(-status => '401 Unauthorized');
        print "Login failed. Invalid credentials.";
    }
}

# Handle team creation request
sub handle_create_team {
    my $team_name = $cgi->param('team_name');
    create_team($team_name);
    print $cgi->redirect(-url => '/teams');
}

# Handle team deletion request
sub handle_delete_team {
    my $team_id = $cgi->param('team_id');
    delete_team($team_id);
    print $cgi->redirect(-url => '/teams');
}

# Handle team update request
sub handle_update_team {
    my $team_id = $cgi->param('team_id');
    my $team_name = $cgi->param('team_name');
    update_team($team_id, $team_name);
    print $cgi->redirect(-url => '/teams');
}

# Handle team member creation request
sub handle_create_team_member {
    my $team_id = $cgi->param('team_id');
    my $member_name = $cgi->param('member_name');
    create_team_member($team_id, $member_name);
    print $cgi->redirect(-url => "/team_members?team_id=$team_id");
}

# Handle team member deletion request
sub handle_delete_team_member {
    my $team_member_id = $cgi->param('team_member_id');
    my $team_id = $cgi->param('team_id');
    delete_team_member($team_member_id);
    print $cgi->redirect(-url => "/team_members?team_id=$team_id");
}

# Handle team member update request
sub handle_update_team_member {
    my $team_member_id = $cgi->param('team_member_id');
    my $team_id = $cgi->param('team_id');
    my $member_name = $cgi->param('member_name');
    update_team_member($team_member_id, $member_name);
    print $cgi->redirect(-url => "/team_members?team_id=$team_id");
}

# Handle team role creation request
sub handle_create_team_role {
    my $team_id = $cgi->param('team_id');
    my $role_name = $cgi->param('role_name');
    create_team_role($team_id, $role_name);
    print $cgi->redirect(-url => "/team_roles?team_id=$team_id");
}

# Handle team role deletion request
sub handle_delete_team_role {
    my $team_role_id = $cgi->param('team_role_id');
    my $team_id = $cgi->param('team_id');
    delete_team_role($team_role_id);
    print $cgi->redirect(-url => "/team_roles?team_id=$team_id");
}

# Handle team role update request
sub handle_update_team_role {
    my $team_role_id = $cgi->param('team_role_id');
    my $team_id = $cgi->param('team_id');
    my $role_name = $cgi->param('role_name');
    update_team_role($team_role_id, $role_name);
    print $cgi->redirect(-url => "/team_roles?team_id=$team_id");
}

# Dispatch requests
sub dispatch {
    my $action = $cgi->param('action') || '';
    my $user = CGI::Session->load()->param('user');
    if ($action eq 'login') {
        show_login();
    } elsif ($action eq 'handle_login') {
        handle_login();
    } elsif ($action eq 'logout') {
        CGI::Session->load()->delete();
        print $cgi->redirect(-url => '/');
    } elsif ($action eq 'admin_panel') {
        show_admin_panel($user);
    } elsif ($action eq 'teams') {
        show_teams($user);
    } elsif ($action eq 'team_members') {
        my $team_id = $cgi->param('team_id') || '';
        show_team_members($user, $team_id);
    } elsif ($action eq 'team_roles') {
        my $team_id = $cgi->param('team_id') || '';
        show_team_roles($user, $team_id);
    } elsif ($action eq 'create_team' && check_csrf_token($cgi)) {
        handle_create_team();
    } elsif ($action eq 'delete_team' && check_csrf_token($cgi)) {
        handle_delete_team();
    } elsif ($action eq 'update_team' && check_csrf_token($cgi)) {
        handle_update_team();
    } elsif ($action eq 'create_team_member' && check_csrf_token($cgi)) {
        handle_create_team_member();
    } elsif ($action eq 'delete_team_member' && check_csrf_token($cgi)) {
        handle_delete_team_member();
    } elsif ($action eq 'update_team_member' && check_csrf_token($cgi)) {
        handle_update_team_member();
    } elsif ($action eq 'create_team_role' && check_csrf_token($cgi)) {
        handle_create_team_role();
    } elsif ($action eq 'delete_team_role' && check_csrf_token($cgi)) {
        handle_delete_team_role();
    } elsif ($action eq 'update_team_role' && check_csrf_token($cgi)) {
        handle_update_team_role();
    } else {
        show_login();
    }
}

# Run the application
dispatch();


