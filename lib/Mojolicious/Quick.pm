use strict;
use warnings;

package Mojolicious::Quick;

use Carp;
use Mojo::Base 'Mojolicious';

# ABSTRACT: A quick way of generating a simple Mojolicious app.

=head1 SYNOPSIS

    use Mojolicious::Quick;

    # Specify routes for all HTTP verbs
    my $app = Mojolicious::Quick->new(
        [   '/thing/:id' => sub {
                my $c  = shift;
                my $id = $c->stash('id');
                $c->render( text => qq{Thing $id} );
            },
            '/other/thing/:id' => sub {
                my $c  = shift;
                my $id = $c->stash('id');
                $c->render( text => qq{Other thing $id} );
            },
            '/another/thing/:id' => sub {
                my $c  = shift;
                my $id = $c->stash('id');
                $c->render( text => qq{Another thing $id} );
            },
        ]
    );

    # Specify different routes for different HTTP verbs
    my $app = Mojolicious::Quick->new(
            GET => [
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Get thing $id} );
                },
                '/other/thing/:id' => sub {
                    my $id = $c->stash('id');
                    $c->render( text => qq{Get other thing $id} );
                }
            ],
            POST => [
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Post thing $id} );
                },
            ],
            PUT => [
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Put thing $id} );
                },
            ],
            PATCH => [
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Patch thing $id} );
                },
            ],
            OPTIONS => [
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Options thing $id} );
                },
            ],
            DELETE => [
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Delete thing $id} );
                },
            ],
        }
    );

    my $ua = $app->ua;
    my $tx = $ua->get('/thing/23'); # Returns body "Get thing 23"

=head1 USE CASE, or "What's the point?"

In developing a client that interfaces with a Web service, you might not always have access to said
Web service. Perhaps you don't have authentication credentials. Perhaps the service is still in 
development.  For whatever reason, if you need to mock up a quick and dirty Web application that you 
can test against, this will allow you to do it.

=attr rewrite_url

If this is turned on, URLs will be rewritten internally to originate from localhost. If you use the
internal user-agent

=attr ua

Instance of L<Mojo::UserAgent>.  Note that this comes from L<Mojo>; it is noted here to remind the 
user that they have it available to them. You can also use this to attach your own instance of 
Mojo::UserAgent if need be.

=cut

has rewrite_url => 0;

my @HTTP_VERBS = qw/GET POST PUT DELETE PATCH OPTIONS/;

sub new {
    my $class  = shift;
    my $routes = shift;

    if ( $routes && ref $routes ne 'ARRAY' ) {
        unshift @_, $routes;
    }
    my $self = $class->SUPER::new(@_);

    while ( my $path = shift @{$routes} ) {
        my $action = shift @{$routes};
        if ( grep { $path eq $_ } @HTTP_VERBS ) {
            my $verb = lc $path;

            $path = $action;
            if ( ref $path ) {
                my @paths;
                eval {
                    @paths = @{$path};
                    1;
                } or do {
                    my $reftype = ref $path;
                    croak qq{Object of type $reftype cannot be coerced into an array};
                };
                while ( my $path = shift @paths ) {
                    $action = shift @paths;
                    $self->routes->$verb( $path, $action );
                }
            }
            else {
                $action = shift @{$routes};
                $self->routes->$verb( $path => $action );
            }
        }
        else {
            $self->routes->any( $path => $action );
        }
    }

    $self->ua->on(
        start => sub {
            my ( $ua, $tx ) = @_;
            $ua->emit( original_request => $tx->req );
            if ( $self->rewrite_url ) {
                $tx->req->url->host('')->scheme('')->port( $ua->server->url->port );
            }
        }
    );

    return $self;
}
1;
