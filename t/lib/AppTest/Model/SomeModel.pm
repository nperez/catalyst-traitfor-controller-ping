package AppTest::Model::SomeModel;
use Moose;
use namespace::autoclean;
extends 'Catalyst::Model';

sub some_method { return 1; }
sub some_other_method { die; }

__PACKAGE__->meta->make_immutable;

1;
__END__
