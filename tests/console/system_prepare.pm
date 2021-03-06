# SUSE's openQA tests
#
# Copyright © 2018 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Execute SUT changes which should be permanent
# Maintainer: Rodion Iafarov <riafarov@suse.com>

use base 'consoletest';
use testapi;
use utils;
use ipmi_backend_utils 'use_ssh_serial_console';
use strict;

sub run {
    my ($self) = @_;
    check_var('BACKEND', 'ipmi') ? use_ssh_serial_console : select_console 'root-console';

    ensure_serialdev_permissions;

    # Stop packagekit as may lock zypper and fail zypper calls, if it's running
    systemctl 'stop packagekit.service' unless script_run('systemctl is-active packagekit.service');
    # Installing a minimal system gives a pattern conflicting with anything not minimal
    # Let's uninstall 'the pattern' (no packages affected) in order to be able to install stuff
    script_run 'rpm -qi patterns-openSUSE-minimal_base-conflicts && zypper -n rm patterns-openSUSE-minimal_base-conflicts';
    # Install curl and tar in order to get the test data
    zypper_call 'install curl tar';

    # BSC#997263 - VMware screen resolution defaults to 800x600
    if (check_var('VIRSH_VMM_FAMILY', 'vmware')) {
        assert_script_run("sed -ie '/GFXMODE=/s/=.*/=1024x768x32/' /etc/default/grub");
        assert_script_run("sed -ie '/GFXPAYLOAD_LINUX=/s/=.*/=1024x768x32/' /etc/default/grub");
        assert_script_run("grub2-mkconfig -o /boot/grub2/grub.cfg");
    }
}

sub test_flags {
    return {milestone => 1, fatal => 1};
}

1;
