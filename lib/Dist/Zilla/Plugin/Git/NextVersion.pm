use strict;
use warnings;

package Dist::Zilla::Plugin::Git::NextVersion;
# ABSTRACT: provide a version number by bumping the last git release tag

use Dist::Zilla 4 ();
use Version::Next ();
use version 0.80 ();

use Moose;
use namespace::autoclean 0.09;
use MooseX::AttributeShortcuts;
use Dist::Zilla::Stash::Repository ();

with
    'Dist::Zilla::Role::Git::ConfigFromStash',
    'Dist::Zilla::Role::VersionProvider',
    ;

# -- attributes
# -- role implementation

sub provide_version {
  my ($self) = @_;

  # override (or maybe needed to initialize)
  return $ENV{V} if exists $ENV{V};

  return $self->first_version
    unless $self->has_previous_versions;

  my $last_ver = $self->last_version;
  my $new_ver  = Version::Next::next_version($last_ver);
  $self->log("Bumping version from $last_ver to $new_ver");

  return "$new_ver";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=for Pod::Coverage
    provide_version

=head1 SYNOPSIS

In your F<dist.ini>:

    [Git::NextVersion]
    first_version = 0.001       ; this is the default
    version_regexp  = ^v(.+)$   ; this is the default

=head1 DESCRIPTION

This does the L<Dist::Zilla::Role::VersionProvider> role.  It finds the last
version number from your git tags, increments it using L<Version::Next>, and
uses the result as the C<version> parameter for your distribution.

The plugin accepts the following options:

=over

=item *

C<first_version> - if the repository has no tags at all, this version
is used as the first version for the distribution.  It defaults to "0.001".

=item *

C<version_regexp> - regular expression that matches a tag containing
a version.  It must capture the version into $1.  Defaults to ^v(.+)$
which matches the default C<tag_format> from L<Dist::Zilla::Plugin::Git::Tag>.
If you change C<tag_format>, you B<must> set a corresponsing C<version_regexp>.

=back

You can also set the C<V> environment variable to override the new version.
This is useful if you need to bump to a specific version.  For example, if
the last tag is 0.005 and you want to jump to 1.000 you can set V = 1.000.

  $ V=1.000 dzil release

=cut

