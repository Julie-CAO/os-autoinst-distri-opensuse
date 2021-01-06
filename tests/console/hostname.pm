# SUSE's openQA tests
#
# Copyright © 2009-2013 Bernhard M. Wiedemann
# Copyright © 2012-2020 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: server hostname setup and check
# - Set hostname as "susetest"
# - If network is down (using ip command)
#   - Reload network
#   - Check network status
#   - Save screenshot
#   - Restart network
#   - Check status
#   - Save screenshot
# - Check network status (using ip command)
# - Save screenshot
# Maintainer: Jozef Pupava <jpupava@suse.com>

use base "consoletest";
use strict;
use warnings;
use testapi;
use utils;
use version_utils "is_sle";

sub run {
    select_console 'root-console';

    # Prevent HOSTNAME from being reset by DHCP
    file_content_replace('/etc/sysconfig/network/dhcp', 'DHCLIENT_SET_HOSTNAME="yes"' => 'DHCLIENT_SET_HOSTNAME="no"');

    set_hostname(get_var('HOSTNAME', 'susetest'));

    # We have to reconnect to be sure that the new hostname is used
    unless (get_var('SET_CUSTOM_PROMPT')) {
        send_key 'ctrl-d';
        reset_consoles;
        select_console 'root-console';
    }
}

sub test_flags {
    return {milestone => 1, fatal => 1};
}

1;
