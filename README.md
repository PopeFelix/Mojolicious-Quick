# NAME

Mojolicious::Quick - A quick way of generating a simple Mojolicious app.

# VERSION

version 0.001

# SYNOPSIS

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

# ATTRIBUTES

## rewrite\_url

If this is turned on, URLs will be rewritten internally to originate from localhost. If you use the
internal user-agent

## ua

Instance of [Mojo::UserAgent](https://metacpan.org/pod/Mojo::UserAgent).  Note that this comes from [Mojo](https://metacpan.org/pod/Mojo); it is noted here to remind the 
user that they have it available to them. You can also use this to attach your own instance of 
Mojo::UserAgent if need be.

# USE CASE, or "What's the point?"

In developing a client that interfaces with a Web service, you might not always have access to said
Web service. Perhaps you don't have authentication credentials. Perhaps the service is still in 
development.  For whatever reason, if you need to mock up a quick and dirty Web application that you 
can test against, this will allow you to do it.

# AUTHOR

Kit Peters &lt;popefelix@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Broadbean Technology.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
