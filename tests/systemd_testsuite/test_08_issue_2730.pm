# SUSE's openQA tests
#
# Copyright © 2019 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Run test executed by TEST-08-ISSUE-2730 from upstream after openSUSE/SUSE patches.
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use base "consoletest";
use warnings;
use strict;
use testapi;
use utils 'zypper_call';
use power_action_utils 'power_action';

sub run {
    #prepare test
    assert_script_run 'cd /var/opt/systemd-tests';
    assert_script_run './run-tests.sh TEST-08-ISSUE-2730 --setup 2>&1 | tee /tmp/testsuite.log', 600;
    assert_script_run 'ls -l /etc/systemd/system/testsuite.service';
    #reboot
    power_action('reboot', textmode => 1);
    assert_screen('linux-login', 600);
    type_string "root\n";
    wait_still_screen 3;
    type_password;
    wait_still_screen 3;
    send_key 'ret';
    # run test
    assert_script_run 'cd /var/opt/systemd-tests';
    assert_script_run './run-tests.sh TEST-08-ISSUE-2730 --run 2>&1 | tee /tmp/testsuite.log', 60;
    assert_screen("systemd-testsuite-test-08-issue-2730");
}

sub test_flags {
    return { always_rollback => 1 };
}

sub post_fail_hook {
    my ($self) = shift;
    $self->SUPER::post_fail_hook;
    assert_script_run('tar -cjf TEST-08-ISSUE-2730-logs.tar.bz2 /var/opt/systemd-tests/logs/');
    upload_logs('TEST-08-ISSUE-2730-logs.tar.bz2');
}


1;
