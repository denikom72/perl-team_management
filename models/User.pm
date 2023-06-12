package User;

use strict;
use warnings;
use Carp;

=head1 NAME

User - Represents a user with email, password, and ID

=head1 SYNOPSIS

    use User;

    my $user = User->new('user@example.com', 'password123', 1);

    # Getters
    my $email = $user->get_email();
    my $password = $user->get_password();
    my $id = $user->get_id();

    # Setters
    $user->set_email('newuser@example.com');
    $user->set_password('newpassword');
    $user->set_id(2);

=head1 DESCRIPTION

The User module represents a user with email, password, and ID. It provides getters and setters for accessing and modifying these properties.

=head1 METHODS

=cut

sub new {
    my ($class, $email, $password, $id) = @_;

    my $self = {
        _email    => undef,
        _password => undef,
        _id       => undef,
    };

    bless $self, $class;

    $self->set_email($email)       if defined $email;
    $self->set_password($password) if defined $password;
    $self->set_id($id)             if defined $id;

    return $self;
}

=head2 get_email

Returns the email of the user.

=cut

sub get_email {
    my ($self) = @_;
    return $self->{_email};
}

=head2 set_email

Sets the email of the user. Performs a plausibility check to ensure the email format is valid.

=cut

sub set_email {
    my ($self, $email) = @_;

    if ($email =~ /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/) {
        $self->{_email} = $email;
    }
    else {
        croak("Invalid email format");
    }
}

=head2 get_password

Returns the password of the user.

=cut

sub get_password {
    my ($self) = @_;
    return $self->{_password};
}

=head2 set_password

Sets the password of the user. Performs a plausibility check to ensure the password contains no hex characters.

=cut

sub set_password {
    my ($self, $password) = @_;

    if ($password =~ /^[^0-9A-Fa-f]+$/) {
        $self->{_password} = $password;
    }
    else {
        croak("Invalid password format");
    }
}

=head2 get_id

Returns the ID of the user.

=cut

sub get_id {
    my ($self) = @_;
    return $self->{_id};
}

=head2 set_id

Sets the ID of the user.

=cut

sub set_id {
    my ($self, $id) = @_;
    $self->{_id} = $id;
}

1;

=head1 AUTHOR

Denis Komnenovic

=cut
