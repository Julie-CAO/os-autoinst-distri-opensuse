# Copyright SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

# Summary: Setup and install more tools in the running jumphost image for qe-sap-deployment
# Maintainer: QE-SAP <qe-sap@suse.de>, Michele Pagot <michele.pagot@suse.com>

use strict;
use warnings;
use Mojo::Base 'publiccloud::basetest';
use testapi;
use qesapdeployment;

sub run {
    my ($self) = @_;
    $self->select_serial_terminal;

    # Get the code for the qe-sap-deployment
    qesap_create_folder_tree();
    qesap_get_deployment_code();
    qesap_pip_install();
}

sub post_fail_hook {
    my ($self) = shift;
    $self->select_serial_terminal;
    qesap_upload_logs('', 1);
    $self->SUPER::post_fail_hook;
}

1;
