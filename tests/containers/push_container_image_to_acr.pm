# SUSE's openQA tests
#
# Copyright SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Push a container image to the Azure Cloud Registry
#
# Maintainer: Ivan Lausuch <ilausuch@suse.com>, qa-c team <qa-c@suse.de>

use Mojo::Base 'publiccloud::basetest';
use testapi;
use containers::urls qw(get_suse_container_urls get_urls_from_var);

sub run {
    my ($self, $args) = @_;

    $self->select_serial_terminal;

    my $provider = $self->provider_factory(service => 'ACR');

    my $image;
    unless ($image = get_urls_from_var('CONTAINER_IMAGES_TO_TEST')->[0]) {
        # Get list of images from CONTAINER_IMAGES_TO_TEST or use the default
        my ($untested_images, $released_images) = get_suse_container_urls();
        $image = $untested_images->[0];
    }
    my $tag = $provider->get_default_tag();

    record_info('Pull', "Pulling $image");
    assert_script_run("podman pull $image", 360);

    my $image_build_format = '{{ index .Config.Labels "org.opencontainers.image.version" }}';
    my $image_build = script_output("podman image inspect $image --format='$image_build_format'");
    record_info('Img version', $image_build);

    my $image_name = $provider->push_container_image($image, $tag);
    record_info('Registry',
        "Image successfully uploaded to ACR:\n$image_name\n" . script_output("podman inspect $image_name"));
}

sub post_fail_hook {
    my ($self) = @_;
    record_info('INFO', "Deleting image $self->tag");
    $self->{provider}->delete_image();
}

sub test_flags {
    return {fatal => 1, milestone => 1};
}

1;
