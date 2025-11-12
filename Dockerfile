# Fedora version (e.g. 32, 33, ...) can be passed using --build-arg=fedora_version=...
ARG fedora_version=latest
FROM registry.fedoraproject.org/fedora:${fedora_version}

# Install required packages.
RUN dnf update -y && \
    dnf --nodocs install -y \
    gnome-session gnome-shell gnome-extensions-app \
    xorg-x11-xinit xorg-x11-server-Xvfb xorg-x11-xauth x11-utils \
    gnome-terminal xdotool xautomation sudo dbus-x11 \
    nodejs npm gettext glib2-devel jq unzip git \
    --skip-unavailable && \
    dnf clean all -y && \
    rm -rf /var/cache/dnf

# Copy system configuration.
COPY etc /etc

# Start Xvfb via systemd on display :99.
# Add the gnomeshell user with no password.
RUN systemctl unmask systemd-logind.service console-getty.service getty.target && \
    systemctl enable xvfb@:99.service && \
    systemctl set-default multi-user.target && \
    adduser -m -U -G users,adm gnomeshell && \
    echo "gnomeshell     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add the scripts.
COPY bin /usr/local/bin

CMD [ "/usr/sbin/init", "systemd.unified_cgroup_hierarchy=0" ]
