## -*- docker-image-name: "scaleway/opensuse:latest" -*-
FROM armbuild/opensuse-disk:13.2
MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)


# Environment
ENV SCW_BASE_IMAGE scaleway/opensuse:latest


# Patch rootfs for docker-based builds
RUN zypper -n -v refresh \
 && zypper -n update \
 && zypper -n install curl \
 && curl -Lq http://j.mp/scw-skeleton | FLAVORS=common,docker-based,systemd bash -e \
 && /usr/local/sbin/builder-enter


# Make the image smaller
# kernel, drivers, firmwares
RUN zypper -n rm kernel-default kernel-firmware
# services
RUN zypper -n rm libmozjs-17_0 bluez cracklib-dict-full


# Install packages
RUN zypper -n install \
    bc \
    shunit2 \
    socat \
    sudo \
    tmux \
    vim \
    wget


# xnbd-client
RUN wget https://github.com/scaleway/image-opensuse/raw/master/packages/xnbd-client/RPMS/armv7hl/xnbd-client-0.3.0-1.armv7hl.rpm \
 && zypper -n install ./xnbd-client-0.3.0-1.armv7hl.rpm \
 && rm -f xnbd-client-0.3.0-1.armv7hl.rpm \
 && ldconfig


# Locale
RUN cd /usr/lib/locale/; ls | grep -v en_US | xargs rm -rf


# Patch rootfs
RUN curl -Lkq http://j.mp/scw-skeleton | FLAVORS=common,docker-based bash -e
ADD ./patches/etc/ /etc/
ADD ./patches/usr/ /usr/


RUN systemctl enable \
	oc-generate-ssh-keys \
	oc-fetch-ssh-keys \
	oc-sync-kernel-modules \
	oc-gen-machine-id


# Remove root password
RUN passwd -d root


# Disable YaST2 on first boot
RUN systemctl disable YaST2-Firstboot.service


RUN systemctl mask                       \
      systemd-modules-load.service       \
      systemd-update-utmp-runlevel       \
      proc-sys-fs-binfmt_misc.automount  \
      systemd-random-seed.service        \
 && systemctl enable                     \
      dev-ttyS0.device                   \
      serial-getty@ttyS0                 \
 && systemctl disable                    \
      wpa_supplicant                     \
      alsa-restore.service               \
      alsa-state.service                 \
      alsa-store.service                 \
      alsasound.service                  \
 && systemctl set-default multi-user

# Clean rootfs from image-builder
RUN /usr/local/sbin/builder-leave
