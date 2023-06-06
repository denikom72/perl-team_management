use strict;
use warnings;
use Test::More;

# Stubs for the database operations
my %teams_db;
my %team_members_db;
my %team_roles_db;

sub create_team {
    my ($team_name) = @_;
    my $team_id = scalar keys %teams_db + 1;
    $teams_db{$team_id} = $team_name;
    return $team_id;
}

sub get_team_name {
    my ($team_id) = @_;
    return $teams_db{$team_id};
}

sub update_team_name {
    my ($team_id, $new_name) = @_;
    $teams_db{$team_id} = $new_name;
}

sub delete_team {
    my ($team_id) = @_;
    delete $teams_db{$team_id};
}

sub create_team_member {
    my ($team_id, $member_name) = @_;
    my $member_id = scalar keys %team_members_db + 1;
    $team_members_db{$team_id}{$member_id} = $member_name;
    return $member_id;
}

sub get_team_member_name {
    my ($team_id, $member_id) = @_;
    return $team_members_db{$team_id}{$member_id};
}

sub update_team_member_name {
    my ($team_id, $member_id, $new_name) = @_;
    $team_members_db{$team_id}{$member_id} = $new_name;
}

sub delete_team_member {
    my ($team_id, $member_id) = @_;
    delete $team_members_db{$team_id}{$member_id};
}

sub create_team_role {
    my ($team_id, $role_name) = @_;
    my $role_id = scalar keys %team_roles_db + 1;
    $team_roles_db{$team_id}{$role_id} = $role_name;
    return $role_id;
}

sub get_team_role_name {
    my ($team_id, $role_id) = @_;
    return $team_roles_db{$team_id}{$role_id};
}

sub update_team_role_name {
    my ($team_id, $role_id, $new_name) = @_;
    $team_roles_db{$team_id}{$role_id} = $new_name;
}

sub delete_team_role {
    my ($team_id, $role_id) = @_;
    delete $team_roles_db{$team_id}{$role_id};
}

# TeamDTO unit tests
sub test_team_dto {
    my $team = TeamDTO->new(
        id   => 1,
        name => 'Team A'
    );

    is($team->id, 1, 'TeamDTO - id getter');
    is($team->name, 'Team A', 'TeamDTO - name getter');
}

# TeamMemberDTO unit tests
sub test_team_member_dto {
    my $team_member = TeamMemberDTO->new(
        id   => 1,
        name => 'John Doe'
    );

    is($team_member->id, 1, 'TeamMemberDTO - id getter');
    is($team_member->name, 'John Doe', 'TeamMemberDTO - name getter');
}

# TeamRoleDTO unit tests
sub test_team_role_dto {
    my $team_role = TeamRoleDTO->new(
        id   => 1,
        name => 'Developer'
    );

    is($team_role->id, 1, 'TeamRoleDTO - id getter');
    is($team_role->name, 'Developer', 'TeamRoleDTO - name getter');
}

# Team creation unit test
sub test_create_team {
    my $team_id = create_team('Team A');
    is($team_id, 1, 'create_team - returns correct team id');
    is(get_team_name($team_id), 'Team A', 'create_team - team name stored correctly');
}

# Team update unit test
sub test_update_team_name {
    my $team_id = create_team('Team A');
    update_team_name($team_id, 'Team B');
    is(get_team_name($team_id), 'Team B', 'update_team_name - team name updated correctly');
}

# Team deletion unit test
sub test_delete_team {
    my $team_id = create_team('Team A');
    delete_team($team_id);
    is(get_team_name($team_id), undef, 'delete_team - team deleted');
}

# Team member creation unit test
sub test_create_team_member {
    my $team_id = create_team('Team A');
    my $member_id = create_team_member($team_id, 'John Doe');
    is($member_id, 1, 'create_team_member - returns correct member id');
    is(get_team_member_name($team_id, $member_id), 'John Doe', 'create_team_member - member name stored correctly');
}

# Team member update unit test
sub test_update_team_member_name {
    my $team_id = create_team('Team A');
    my $member_id = create_team_member($team_id, 'John Doe');
    update_team_member_name($team_id, $member_id, 'Jane Smith');
    is(get_team_member_name($team_id, $member_id), 'Jane Smith', 'update_team_member_name - member name updated correctly');
}

# Team member deletion unit test
sub test_delete_team_member {
    my $team_id = create_team('Team A');
    my $member_id = create_team_member($team_id, 'John Doe');
    delete_team_member($team_id, $member_id);
    is(get_team_member_name($team_id, $member_id), undef, 'delete_team_member - member deleted');
}

# Team role creation unit test
sub test_create_team_role {
    my $team_id = create_team('Team A');
    my $role_id = create_team_role($team_id, 'Developer');
    is($role_id, 1, 'create_team_role - returns correct role id');
    is(get_team_role_name($team_id, $role_id), 'Developer', 'create_team_role - role name stored correctly');
}

# Team role update unit test
sub test_update_team_role_name {
    my $team_id = create_team('Team A');
    my $role_id = create_team_role($team_id, 'Developer');
    update_team_role_name($team_id, $role_id, 'Tester');
    is(get_team_role_name($team_id, $role_id), 'Tester', 'update_team_role_name - role name updated correctly');
}

# Team role deletion unit test
sub test_delete_team_role {
    my $team_id = create_team('Team A');
    my $role_id = create_team_role($team_id, 'Developer');
    delete_team_role($team_id, $role_id);
    is(get_team_role_name($team_id, $role_id), undef, 'delete_team_role - role deleted');
}

# Run the tests
test_team_dto();
test_team_member_dto();
test_team_role_dto();
test_create_team();
test_update_team_name();
test_delete_team();
test_create_team_member();
test_update_team_member_name();
test_delete_team_member();
test_create_team_role();
test_update_team_role_name();
test_delete_team_role();

done_testing();

