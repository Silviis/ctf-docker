FROM kalilinux/kali-rolling
ENV USERNAME=kali
ARG ZSH_THEME=htb
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt update
# Separate big packages to use docker cache more efficiently
RUN apt install -y --no-install-recommends \
        seclists \
        wordlists
RUN gunzip -f /usr/share/wordlists/rockyou.txt.gz

RUN apt install -y --no-install-recommends \
        curl \ 
        dialog \
        dnsutils \
        file \
        iproute2 \
        iputils-ping \
        nano \
        netcat-openbsd \
        openvpn \
        psmisc \
        sudo \
        unzip \
        wget \
        zsh

RUN apt install -y --no-install-recommends \
        burpsuite \
        ffuf \
        gdb \
        ghidra \
        git \
        gobuster \
        hashcat \
        hydra \
        john \
        jq \
        ldap-utils \
        nmap \
        python3-opencv \
        python3-pillow \
        python3-pip \
        python3-requests \
        python3-unicorn \
        python3-venv \
        python3-zbar \
        rlwrap \
        smbclient \
        sqlmap \
        strace \
        tcpdump


# Add new user as a sudoer. Replace UID/GID 1000 if your host uses different values.
RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        usermod  --uid 1000 $USERNAME && \
        groupmod --gid 1000 $USERNAME

# oh-my-zsh
USER $USERNAME
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
RUN sed -i "s!robbyrussell!${ZSH_THEME}!g" /home/$USERNAME/.zshrc  # Replace default theme
RUN sudo chsh -s /bin/zsh $USERNAME
RUN echo 'if [ -f /workspaces/ctf-vscode-container/scripts/htb.sh ]; then source /workspaces/ctf-vscode-container/scripts/htb.sh; fi' >> ~/.zshrc
