package Catalyst::TraitFor::Controller::Ping;

#ABSTRACT: Provides a ping action for consuming controllers

use MooseX::MethodAttributes::Role;
use namespace::autoclean;
use Try::Tiny;

=attribute_public model_name
 
 isa: Str, is: ro

Define a model name to access via $c->model();

=cut

has model_name => (isa => 'Str', is => 'ro', predicate => 'has_model_name', clearer => '_clear_model_name', writer => '_set_model_name');

=attribute_public model_method

 isa: Str, is: ro

Define a method name to call upon the model

=cut

has model_method => (isa => 'Str', is => 'ro', predicate => 'has_model_method', clearer => '_clear_model_method', writer => '_set_model_method');

=attribute_public model_method_arguments
 
 isa: ArrayRef, is: ro

Define arguments to pass to the method upon the model

=cut

has model_method_arguments => (isa => 'ArrayRef', is => 'ro', predicate => 'has_model_method_arguments', clearer => '_clear_model_method_arguments', writer => '_set_model_method_arguments');

=method_public ping

 :Local

ping is an action added to which ever controller consumes this role that simply returns. If a L</model_name> is configured, the model will be gathered via $c->model(). If L</model_method> is configured, that method will be called upon the retrived model. If L</model_method_arguments> are provided, they will be passed to the model method. The return value is discarded. Only that the method executed without exception matters for ping. Ping will return no content so it doesn't forward to views or anything else.

=cut

sub ping :Local 
{
    my ($self, $c) = @_;
    
    if($self->has_model_name)
    {
        my $model = $c->model($self->model_name);

        if(!defined($model))
        {
            $c->error("Unable to find model '${\$self->model_name}'");
            $c->detach();
        }
        elsif($self->has_model_method)
        {
            my $args;

            if($self->has_model_method_arguments)
            {
                $args = $self->model_method_arguments;
            }

            try 
            {
                $model->${\$self->model_method}(@$args);
            }
            catch
            {
                $c->error("Problem calling '${\$self->model_method}' on '${\$self->model_name}': $_");
                $c->detach();
            }
        }
    }
}

1;
__END__

=head1 SYNOPSIS

 package MyApp::Controller::Foo;
 use Moose;
 use namespace::autoclean;
 BEGIN { extends 'Catalyst::Controller' }

 with 'Catalyst::TraitFor::Controller::Ping';

 __PACKAGE__->config
 (
    {
        model_name => 'SomeModel',
        model_method => 'some_method',
        model_method_arguments => [qw/ one two three /],
    }
 );

 ...

=head1 DESCRIPTION

Ever wanted to monitor a web app? With this simple role, you can easily add an action to L</ping> to test if the app is up and running. You can even define a L</model_name> and a L</model_method> to call so it perihperally tests the app's connection to the database (or some other resource). Simply add exceptions for L</ping> in your ACL, and you're good to go.

