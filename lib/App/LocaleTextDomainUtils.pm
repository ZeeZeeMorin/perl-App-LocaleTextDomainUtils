package App::LocaleTextDomainUtils;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

our %SPEC;

our %args_common = (
    search_dirs => {
        'x.name.is_plural' => 1,
        'x.name.singular' => 'search_dir',
        schema => ['array*', of=>'str*'],
        cmdline_aliases => {I=>{}},
    },
    textdomain => {
        schema => 'str*',
        pos => 0,
    },
);

$SPEC{list_localedata_dirs} = {
    v => 1.1,
    summary => 'Print list of LocaleData directories to be used to search for *.mo files',
    description => <<'_',

If search_dirs is specified, then will use search_dirs.

Otherwise, will use:

    dist_dir($textdomain) + ("/locale", "/LocaleData")
    @INC + "/LocaleData"
    default ("/usr/share/locale" OR "/usr/local/share/locale") + "/LocaleData"

_
    args => {
        %args_common,
    },
    result_naked => 1,
};
sub list_localedata_dirs {
    my %args = @_;

    my @res;

    if ($args{search_dirs} && @{ $args{search_dirs} }) {
        push @res, $_ for @{ $args{search_dirs} };
    } else {
        # dist-dir(textdomain)
        if (defined $args{textdomain}) {
            my $sharedir = eval {
                require File::ShareDir;
                File::ShareDir::dist_dir($args{textdomain});
            };
            if ($sharedir) {
                push @res, "$sharedir/locale", "$sharedir/LocaleData";
            }
        }

        # @INC
        for (@INC) {
            push @res, "$_/LocaleData" unless ref $_;
        }

        # default dir
        for ("/usr/share/locale", "/usr/local/share/locale") {
            if (-d $_) {
                push @res, "$_/LocaleData";
                last;
            }
        }
    }

    \@res;
}

$SPEC{list_mo_files} = {
    v => 1.1,
    summary => 'List .mo files',
    description => <<'_',

Will look for inside each localedata dirs.

_
    args => {
        %args_common,
    },
    result_naked => 1,
};
sub list_mo_files {
    my %args = @_;
    my $textdomain = $args{textdomain};

    my $localedata_dirs = list_localedata_dirs(%args);

    my @res;
    for my $dir (@$localedata_dirs) {
        if (defined $textdomain) {
            push @res, glob("$dir/*/LC_MESSAGES/$textdomain.mo");
        } else {
            push @res, glob("$dir/*/LC_MESSAGES/*.mo");
        }
    }

    \@res;
}

1;
#ABSTRACT: Utilities related to Locale::TextDomain

=for Pod::Coverage ^(.+)$

=head1 DESCRIPTION

This distributions provides the following command-line utilities:

# INSERT_EXECS_LIST


=head1 SEE ALSO

L<Locale::TextDomain>

=cut
