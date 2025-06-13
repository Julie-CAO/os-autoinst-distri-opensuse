# SUSE's openQA tests
#
# Copyright 2016-2017 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Package: virt-install tigervnc
# Summary: 'virt-install' test
# Maintainer: aginies <aginies@suse.com>

use base 'x11test';
use strict;
use warnings;
use testapi;

sub run {
    ensure_installed('virt-install');
    x11_start_program('xterm');
    become_root;
    script_run('virt-install --name TESTING --osinfo detect=on,require=off --memory 512 --disk none --boot cdrom --graphics vnc &', 0);
    wait_still_screen(15);
    if (check_screen('allow-inhibiting-shortcuts', 10)) {
	    #        send_key('left');
        send_key('ret');
        save_screenshot;
    }
    send_key "super" for (0 .. 2);
    record_info("Typed 3 times 'super'", "");
    sleep 1;
    save_screenshot;
    send_key "super-alt-f2";
    record_info("Typed 'super-alt-f2'", "");
    sleep 1;
    save_screenshot;
    send_key "alt-f4";
    record_info("Typed 'alt-f4'", "");
    sleep 1;
    save_screenshot;
    send_key "super-alt-f4";
    record_info("Typed 'super-alt-f4'", "");
    save_screenshot;


    #send_key "shift-f12";
    x11_start_program('vncviewer :0', target_match => 'virtman-gnome_virt-install', match_timeout => 100);
    # closing all windows
    # julie debug
    #send_key 'alt-f4' for (0 .. 2);
    sleep 3600;
}

1;
