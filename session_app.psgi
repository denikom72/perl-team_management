use strict;
use warnings;
use Plack::Request;
use Plack::Response;
use Plack::Builder;
use Digest::SHA qw(sha256_hex);
use Data::Dumper;
use Template;
use DBI;
use CGI::Session;
#use Plack::Session;

use lib "model";
use MemberDTO;
use MemberDAO;

use TeamDTO;
use TeamDAO;

use Database; 


my ( $tpl, $vars, $session, $member, $memb );

# Configure the database connection
#my $db_file = 'team_management.db';
#my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file") or die "Couldn't connect to database: $DBI::errstr";


my $db = Database->new('team_management.db');



# Set up the template engine
my $template = Template->new({
    INCLUDE_PATH => './views',
    INTERPOLATE  => 1,
    CACHE_SIZE => 64 
}) or die "Couldn't initialize template: $Template::ERROR";


#### THE BEGINNING OF THE RBAC CONSTRUCTION #####

my %methods = (
	team_members => \&team_members,
	team_roles => \&team_roles,
	teams => \&teams,
	logged_in_member => \&logged_in_member	
);

#### END OF RBAC ####

sub logged_in_member {
	
	$memb = new MemberDAO($db)->pull_member_by_id( $memb );
			
        return { 
		memberMail => $memb->get_email,
		memberName => $memb->get_name,
		#memberId => $memb->get_id,
		memberTeam => $memb->get_member_team,
		memberRole => $memb->get_member_role,
		content => "<a href='/logout'>logout</a>"
	};

}


sub teams {
	my $team_list;
	$team_list = TeamDAO->new($db)->get_teams();
	
	print STDERR '\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n';
	print STDERR Dumper $team_list;
	print STDERR '\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n';
	
	return { 
		
		team_list => $team_list,
                content => "<a href='/logout'>logout</a>"
	};	

};

sub team_members {
	
	my $args = shift;
	
	my $team_members;
	
	my $teamDTO = TeamDTO->new();
	$teamDTO->set_name($args->{team_name});

	$team_members = MemberDAO->new($db)->get_team_members( $teamDTO );
	
	print STDERR '\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n';
	print STDERR Dumper $team_members;
	#print STDERR Dumper $args;
	print STDERR '\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n';
	
	
	#map {
	
	#} @$team_members;

	return { 
		
		team_name => $teamDTO->get_name(),
		team_members => $team_members,
                content => "<a href='/logout'>logout</a>"
	};	
	print STDERR "I AM INTO rolesRSSSSSSSSSSSSSSSSSSSSSSSS";
};

sub team_roles {
	print STDERR "I AM INTO rolesRSSSSSSSSSSSSSSSSSSSSSSSS";
	
};



my $loginpage = sub {
    
    my $env = shift;
    my $req = Plack::Request->new($env);
    
    my $csrf_token = generate_csrf_token();
    
    #TODO: how to set here the session-state-cookie expiration?

    my $res = Plack::Response->new(200);
    $res->content_type('text/html');
   
    # Define vars for Response 
    my $html = '';
    my $vars = { login_count => undef, csrf_token => $csrf_token };
    my $tpl = "login.tmpl";
    
    # Build Html Answer 
    my $template_context = $template->context;
    unless ( $template_context->template($tpl)->_is_cached ) { 
         $template->process($tpl, { vars => $vars }, \$html) or die "Template processing failed: $template::ERROR";
    }

    # Response
    $res->body($html);
    return $res->finalize;
};

my $logged_in_or_rejected = sub {
    my $env = shift;
    
    my $req = Plack::Request->new($env);

    my $res = Plack::Response->new(200);

    my $check_credentials = undef; 

#    # Validate CSRF token
#    my $is_valid = $req->method eq 'POST' && $req->param('csrf_token') eq $session->param('csrf_token');
    
    $memb = MemberDTO->new( { email => $req->param('username'), password => $req->param('password') } );
    
    my $memb_dao = MemberDAO->new( $db );
    
    $check_credentials = $memb_dao->check_member( $memb );
   my $tst = undef; 
    
    if( $memb->get_id ){
    
	$session = CGI::Session->new();
        my $cookie = $session->cookie();
	$session->load( $cookie );
	
        $res->header('Set-Cookie' => $cookie);
	
	$res->content_type('text/html');
        
        my $html = '';
        
        my  $vars = { membermail => $memb->get_email(), content => "<a href='/logout'>logout</a>" };
        $tpl = "admin_panel.tmpl";
        
        my $template_context = $template->context;
        unless ( $template_context->template($tpl)->_is_cached ) { 
             $template->process($tpl, { vars => $vars }, \$html) or die " Template processing failed: $template::ERROR";
        }

        $res->body($html);
    } else {
    	$res->redirect("/", 302);
    }
    
    return $res->finalize;
};


my $logout = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    delete $env->{'HTTP_COOKIE'};
    my $res = Plack::Response->new();
    $res->redirect("/", 302);
    return $res->finalize;
};


my $admin_panel_crud = sub {

    my $env = shift;
    my $req = Plack::Request->new($env);
    my $submitted_session = $req->session;
     
    #TODO:
    #check_csrf_token();
    #check_session_id
    
    #if( checks ore done ) { call the action pm with params - for example show team or delete team, but with rbac, cause check give as membername and memberrole too. logout always necessary here, Use DTOs. If credentials aren't valide just redirect to login page  } 

    my $res = Plack::Response->new(200);
  
    # Parse hexa into chars 
    $req->{env}->{HTTP_COOKIE} =~ s/\\x\{([0-9A-Fa-f]+)\}/chr(hex($1))/eg; 
    
    my $session_cookie = sprintf( "%s", [ split( /=/, [ split( /;/, $req->{env}->{HTTP_COOKIE} ) ]->[1] ) ]->[1] );
    $session_cookie =~ s/^\s*|\s*$//gi;
    
    if( $session->id eq $session_cookie ){
    
	#print STDERR Dumper $req;
	print STDERR "::::::::::::::::::::::::::::::::::::::::";
	#print STDERR sprintf( "%s", [ split(/=/, $req->{env}->{QUERY_STRING}) ]->[1] ) . "\n";
	print STDERR Dumper [ split(/=/, $req->{env}->{QUERY_STRING}) ];
        
	
	$res->content_type('text/html');
        
	my $action;

        my $html = '';
        
        my $vars = { membermail => $memb->get_email, content => "<a href='/logout'>logout</a>" };
        
	$tpl = "admin_panel.tmpl";

	
	my $query_parts = [ split( /=/, $req->{env}->{QUERY_STRING} ) ];

	my $amp = undef;	
	$query_parts = [ split( /&/, $req->{env}->{QUERY_STRING} ) ] if $req->{env}->{QUERY_STRING} =~ /&/;
		
	if( $req->{env}->{QUERY_STRING} =~ /&/ ){
		my %args;
		my $key_val;
		map {
			$key_val = [ split /=/ ];

			$args{ sprintf( "%s", $key_val->[0] ) }= sprintf( "%s", $key_val->[1] );	
		} @$query_parts;		

		$action = sprintf( "%s", [ split( /=/, $query_parts->[0] ) ]->[1] );

		$vars = $methods{$action}->(\%args);
	} else {
			
		$action = sprintf( "%s", $query_parts->[1] );
	
		$vars = $methods{$action}->();
	}
	
	$tpl = $action . ".tmpl";

        
	print STDERR '????????????????????????????????????????????????????????';
	print STDERR Dumper $vars;	
        
	
	my $template_context = $template->context;
        unless ( $template_context->template($tpl)->_is_cached ) { 
             $template->process($tpl, { vars => $vars }, \$html) or die " Template processing failed: $template::ERROR";
        }

        $res->body($html);
    } else {
    	$res->redirect("/loginpage", 302);
    }
    
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
    enable 'Static',
            path => qr!^/(public|assets|favicon|yui)/!,
            root => '/home/sw-engineer/perl_projects/perl-team_management';
    enable 'CSRFBlock',
	    parameter_name => 'csrf_secret',
	    token_length => 20,
	    session_key => 'csrf_token',
	    blocked => sub {
	      [302, [Location => '/'], ['']];
	    },
	    onetime => 0;
    mount "/" => $loginpage;
    mount "/login" => $logged_in_or_rejected;
    mount "/logout" => $logout;
    mount "/admin_panel" => $admin_panel_crud;
    mount "/favicon.ico" => sub { return [ 200, ['Content-Type' => 'text/html'], [ '404 Not Found' ] ] };
    mount "/assets/style.css" => sub { return [ 200, ['Content-Type' => 'text/css'], [ '404 Not Found' ] ] };
    #mount "/" => $app;
};

