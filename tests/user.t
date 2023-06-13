use strict;
use warnings;
use Test::More;
use Try::Tiny;

use Cwd;
use lib getcwd() . "/../models/";
use lib "/home/sw-engineer/perl_projects/perl-team_management/models/";
use User;

# Test constructor and getters
sub test_constructor_and_getters {
    my $user = User->new('user@example.com', 'password123');
    
    is($user->get_email(), 'user@example.com', 'Email getter returns correct value');
    is($user->get_password(), 'password123', 'Password getter returns correct value');
    #is($user->get_id(), 1, 'ID getter returns correct value');
}

# Test email setter with valid email
sub test_set_email_valid {
    my $user = User->new();
    
    try {
        $user->set_email('user@example.com');
        pass('Email setter accepted valid email');
    }
    catch {
        fail("Email setter threw an error: $_");
    };
}

# Test email setter with invalid email
sub test_set_email_invalid {
    my $user = User->new();
    
    try {
        $user->set_email('invalid_email');
        fail('Email setter accepted invalid email');
    }
    catch {
        like($_, qr/Invalid email format/, 'Email setter threw an error for invalid email');
    };
}

# Test password setter with valid password
sub test_set_password_valid {
    my $user = User->new();
    
    try {
        $user->set_password('newpassword');
        pass('Password setter accepted valid password');
    }
    catch {
        fail("Password setter threw an error: $_");
    };
}

# Test password setter with invalid password
sub test_set_password_invalid {
    my $user = User->new();
    
    try {
        $user->set_password('pass');
        fail('Password setter accepted invalid password');
    }
    catch {
        like($_, qr/Password must be at least 6 characters long/, 'Password setter threw an error for invalid password');
    };
}

# Test id setter with valid id
sub test_set_id_valid {
    my $user = User->new();
    
    try {
        $user->set_id(2);
        pass('ID setter accepted valid ID');
    }
    catch {
        fail("ID setter threw an error: $_");
    };
}

# Test id setter with invalid id
sub test_set_id_invalid {
    my $user = User->new();
    
    try {
        $user->set_id('two');
        fail('ID setter accepted invalid ID');
    }
    catch {
        like($_, qr/ID must be a positive integer/, 'ID setter threw an error for invalid ID');
    };
}

# Run tests
test_constructor_and_getters();
test_set_email_valid();
test_set_email_invalid();
test_set_password_valid();
test_set_password_invalid();
test_set_id_valid();
test_set_id_invalid();

done_testing();

