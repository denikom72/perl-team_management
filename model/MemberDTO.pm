package MemberDTO;

=head1 NAME

Member - Represents a member with email, password, and ID

=head1 SYNOPSIS

    use Member;

    my $member = Member->new({ email => 'member@example.com', password => 'password123', name => 'member1' } );

    # Getters
    my $email = $member->get_email();
    my $password = $member->get_password();
    my $id = $member->get_id();

    # Setters
    try {
        $member->set_email('newmember@example.com');
        $member->set_password('newpassword');
        $member->set_name(member2);
    }
    catch {
        print "Error: $_\n";
    };

=head1 DESCRIPTION

The Member module represents a member with email, password, and ID. It provides getters and setters for accessing and modifying these properties.

=head1 METHODS

=cut



use strict;
use warnings;
use Carp;
use Try::Tiny;
use Data::Dumper;
sub new {
    my ($class, $data ) = @_;

    my $self = {
        _email    => undef,
        _password => undef,
	_name	  => undef,
        _id       => undef,
    };



    bless $self, $class;


    try {
	if( defined $data ){
           $self->set_email( $data->{email} );
	   #$self->set_name( $data->{name} );
       	   $self->set_password( $data->{password} );
	}
    }
    catch {
        croak("Error creating member: $_");
    };

    return $self;
}


sub get_email {
    my ($self) = @_;
    return $self->{_email};
}

=head2 set_email
Sets the email of the member. Performs a plausibility check to ensure the email format is valid.
=cut

sub set_email {
    my ($self, $email) = @_;
    #if ($email =~ /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/) {
    if ($email) {
        $self->{_email} = $email;
    }
    else {
        croak("Invalid email format");
    }
}

sub get_member_role {
    my ($self) = @_;
    return $self->{_role};
}


sub set_member_role {
    my ($self, $role) = @_;
    #	if($role){
    if ($role =~ /^[0-9A-Za-z-_]+$/) {
        $self->{_role} = $role;
    }
    else {
        croak("Invalid role format");
    }
}

sub get_member_team {
    my ($self) = @_;
    return $self->{_team};
}


sub set_member_team {
    my ($self, $team) = @_;
    #	if($team){
    if ($team =~ /^[0-9A-Za-z-_]+$/) {
        $self->{_team} = $team;
    }
    else {
        croak("Invalid team format");
    }
}


sub get_name {
    my ($self) = @_;
    return $self->{_name};
}


sub set_name {
    my ($self, $name) = @_;

    if ($name =~ /^[0-9A-Za-z-]+$/) {
        $self->{_name} = $name;
    }
    else {
        croak("Invalid name format");
    }
}


sub get_password {
    my ($self) = @_;
    return $self->{_password};
}


sub set_password {
    my ($self, $password) = @_;

    if ($password =~ /^[0-9A-Za-z]+$/) {
        $self->{_password} = $password;
    }
    else {
        croak("Invalid password format");
    }
}

sub get_id {
    my ($self) = @_;
    return $self->{_id};
}


sub set_id {
    my ($self, $id) = @_;

    if ($id =~ /^[1-9]\d*$/) {
        $self->{_id} = $id;
    }
    else {
        croak("Invalid ID format");
    }
}


#sub get_data {
#    my ($self) = @_;
#    return $self;
#}


sub set_data {
    my ($self, $data) = @_;
    
	print STDERR 'QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ\n';
	print STDERR Dumper $data;
	print STDERR 'QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ\n';
    try {
	if( defined $data ){

	print STDERR 'QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ\n';
	print STDERR Dumper $data;
	print STDERR 'QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ\n';
	   $self->set_id( $data->{member_id} );
           $self->set_email( $data->{member_email} );
           $self->set_name( $data->{member_name} );
           $self->set_member_role( $data->{member_role_name} );
           $self->set_member_team( $data->{member_team_name} );
	   #$self->set_password( $data->{password} );
	}
    }
    catch {
        croak("Error creating member: $_");
    };

    #$self;
}

1;


=head1 AUTHOR

Denis Komnenovic

=cut
