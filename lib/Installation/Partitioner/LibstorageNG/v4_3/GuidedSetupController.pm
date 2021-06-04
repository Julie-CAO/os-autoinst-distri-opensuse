# SUSE's openQA tests
#
# Copyright © 2021 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved. This file is offered as-is,
# without any warranty.

# Summary: The class introduces business actions for Guided Setup of
# Libstorage-NG Partitioner using REST API.
#
# Maintainer: QE YaST <qa-sle-yast@suse.de>

package Installation::Partitioner::LibstorageNG::v4_3::GuidedSetupController;

use strict;
use warnings;

use YuiRestClient;

use Installation::Partitioner::LibstorageNG::v4_3::FilesystemOptionsPage;
use Installation::Partitioner::LibstorageNG::v4_3::PartitioningSchemePage;
use Installation::Partitioner::LibstorageNG::v4_3::SelectDisksToUsePage;

=head1 PARTITION_SETUP

=head2 SYNOPSIS

The class introduces business actions for Guided Setup of Libstorage-NG
Partitioner using REST API.

=cut

sub new {
    my ($class, $args) = @_;
    my $self = bless {}, $class;
    return $self->init($args);
}

sub init {
    my ($self, $args) = @_;
    $self->{FilesystemOptionsPage}  = Installation::Partitioner::LibstorageNG::v4_3::FilesystemOptionsPage->new({app => YuiRestClient::get_app()});
    $self->{PartitioningSchemePage} = Installation::Partitioner::LibstorageNG::v4_3::PartitioningSchemePage->new({app => YuiRestClient::get_app()});
    $self->{SelectDisksToUsePage}   = Installation::Partitioner::LibstorageNG::v4_3::SelectDisksToUsePage->new({app => YuiRestClient::get_app()});
    return $self;
}

sub get_partitioning_scheme_page {
    my ($self) = @_;
    die "Partitioning Scheme is not displayed" unless $self->{PartitioningSchemePage}->is_shown();
    return $self->{PartitioningSchemePage};
}

sub get_filesystem_options_page {
    my ($self) = @_;
    die "Filesystem Options is not displayed" unless $self->{FilesystemOptionsPage}->is_shown();
    return $self->{FilesystemOptionsPage};
}

sub get_select_disks_to_use_page {
    my ($self) = @_;
    die "Disk to use selection page is not displayed" unless $self->{SelectDisksToUsePage}->is_shown();
    return $self->{SelectDisksToUsePage};
}

sub setup_disks_to_use {
    my ($self, @disks) = @_;
    $self->get_select_disks_to_use_page()->select_hard_disks(@disks);
    $self->get_select_disks_to_use_page()->press_next();
}

sub setup_partitioning_scheme {
    my ($self) = @_;
    $self->get_partitioning_scheme_page()->press_next();
}

sub setup_filesystem_options {
    my ($self, $args) = @_;
    if (my $fs = $args->{root_filesystem_type}) {
        $self->get_filesystem_options_page()->select_root_filesystem($fs);
    }
    $self->get_filesystem_options_page()->press_next();
}

1;
