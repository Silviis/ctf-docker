#!/bin/bash


ENV_FILE="/workspaces/ctf-vscode-container/.env"

if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
else
    echo "[-] Warning: $ENV_FILE not found"
fi

unset TARGET_HOSTNAME TARGET_IP TARGET_HOSTNAME_HTB HTB_MACHINE_NAME HTB_MACHINE_IP MACHINES_DIR

# Ensure the API key is set
if [[ -z "$HTB_APIKEY" ]]; then
    echo "[-] Error: HTB API key (HTB_APIKEY) is not set. Export it as an environment variable."
    return 1
fi

echo "[*] Fetching active HTB machine..."

# Get active machine name
HTB_MACHINE_NAME=$(curl -s --location --request GET "https://labs.hackthebox.com/api/v4/machine/active" \
    -H "Authorization: Bearer $HTB_APIKEY" | jq -r '.info.name')

# Ensure a valid machine name is retrieved
if [[ -z "$HTB_MACHINE_NAME" || "$HTB_MACHINE_NAME" == "null" ]]; then
    echo "[-] Error: Could not fetch active machine name from HTB API."
    return 1
fi

echo "[+] Active machine: $HTB_MACHINE_NAME"

# Get machine IP
HTB_MACHINE_IP=$(curl -s --location --request GET "https://labs.hackthebox.com/api/v4/machine/profile/${HTB_MACHINE_NAME}" \
    -H "Authorization: Bearer $HTB_APIKEY" | jq -r '.info.ip')

if [[ -z "$HTB_MACHINE_NAME" || "$HTB_MACHINE_NAME" == "null" ]]; then
    echo "[-] Error: HTB_MACHINE_NAME is empty or invalid!"
    return 1
fi

if [[ -z "$HTB_MACHINE_IP" || "$HTB_MACHINE_IP" == "null" ]]; then
    echo "[-] Error: HTB_MACHINE_IP is empty or invalid!"
    return 1
fi

export TARGET_HOSTNAME="$HTB_MACHINE_NAME"
export TARGET_IP="$HTB_MACHINE_IP"
export TARGET_HOSTNAME_HTB="${HTB_MACHINE_NAME}.htb"

echo "[+] Environment variables set:"
echo "    TARGET_HOSTNAME=$TARGET_HOSTNAME"
echo "    TARGET_IP=$TARGET_IP"
echo "    TARGET_HOSTNAME_HTB=$TARGET_HOSTNAME_HTB"

MACHINES_DIR="/workspaces/ctf-vscode-container/htb/machines/$HTB_MACHINE_NAME"

# Function to update or add entry in /etc/hosts
update_or_add_host() {
    local hostname=$1
    local ip=$2
    if ! grep -q "$hostname" /etc/hosts; then
        echo "$ip $hostname" | sudo tee -a /etc/hosts > /dev/null
    fi
}

# Function to create machine directory if it doesn’t exist
create_machine_dir() {
    if [[ ! -d "$MACHINES_DIR" ]]; then
        mkdir -p "$MACHINES_DIR"
        echo "[+] Created directory: $MACHINES_DIR"
    else
        echo "[*] Directory already exists: $MACHINES_DIR"
    fi
    cd "$MACHINES_DIR"
}

# Update /etc/hosts with both normal and HTB hostnames
update_or_add_host "$TARGET_HOSTNAME" "$TARGET_IP"
update_or_add_host "$TARGET_HOSTNAME_HTB" "$TARGET_IP"

# Create machine directory
create_machine_dir


echo "[✓] Setup complete for $HTB_MACHINE_NAME ($HTB_MACHINE_IP)"


alias openvpn-lab="sudo -b openvpn /workspaces/ctf-vscode-container/htb/ovpn/machines_eu-4.ovpn"
alias openvpn-competitive="sudo -b openvpn /workspaces/ctf-vscode-container/htb/ovpn/competitive.ovpn"
alias htb-nmap="nmap -sC -sV $TARGET_HOSTNAME -oN /workspaces/ctf-vscode-container/htb/machines/$TARGET_HOSTNAME/initial.nmap -p- --min-rate 5000"
alias revshell="rlwrap nc -lvp 40169"
alias ffuf-subdomains="ffuf -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt -H 'Host: FUZZ.\$TARGET_HOSTNAME_HTB' -u http://\$TARGET_HOSTNAME_HTB -ac -o /workspaces/ctf-vscode-container/htb/machines/\$TARGET_HOSTNAME/ffuf_subdomain.txt"
alias ffuf-directories="ffuf -u http://\$TARGET_HOSTNAME_HTB/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-medium.txt -ac -o /workspaces/ctf-vscode-container/htb/machines/\$TARGET_HOSTNAME/ffuf_directories.txt"
