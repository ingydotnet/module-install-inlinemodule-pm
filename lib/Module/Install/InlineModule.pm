use strict; use warnings;
package Module::Install::InlineModule;
our $VERSION = '0.01';

use base 'Module::Install::Base';
use Inline::Module;

# use XXX;

sub inline {
    my ($self, %args) = @_;

    my $makemaker = {};
    my $postamble = Inline::Module::postamble(
        $makemaker,
        inline => \%args,
    );
    $self->postamble($postamble);
    my $IM = $Inline::Module::Self;
    for my $module ($IM->included_modules) {
        $self->include($module);
    }
}

1;
