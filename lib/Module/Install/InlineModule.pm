use strict; use warnings;
package Module::Install::InlineModule;
our $VERSION = '0.01';

use base 'Module::Install::Base';

use IO::All;

use XXX;

sub inline {
    my ($self, %args) = @_;
    die "'inline' directive requires 'module' key/val pair"
        unless $args{module};
    $args{ilsm} ||= 'Inline::C';

    $self->include('Inline');
    $self->include('Inline::denter');
    $self->include($args{ilsm});
    $self->include('Inline::C::Parser::RegExp');
    $self->include('Inline::Module');
    $self->include('Inline::Module::MakeMaker');

    my $makefile = io('Makefile')->all;
    $makefile =~ s/^pure_all(\s+):(\s+)/pure_all$1::$2/;
    $makefile .= <<"...";

pure_all ::
\t\$(PERL) "-Ilib" "-M$pkg" -e "print '$pkg'->_requires_report()"

...

    return $self;
}

    my $code_modules = $INLINE->{module};
    my $inlined_modules = $INLINE->{inline};
    my @included_modules = included_modules();

    my $section = <<"...";
distdir ::
\t\$(NOECHO) \$(ABSPERLRUN) -MInline::Module=distdir -e 1 -- \$(DISTVNAME) @$inlined_modules -- @included_modules

pure_all ::
...

    for my $module (@$code_modules) {
        $section .=
            "\t\$(NOECHO) \$(ABSPERLRUN) -Iinc -Ilib -e 'use $module'\n";
    }
    $section .=
        "\t\$(NOECHO) \$(ABSPERLRUN) -Iinc -MInline::Module=fixblib -e 1";

    return $section;
1;
