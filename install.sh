#!/bin/bash

# Hàm để in trạng thái thành công hoặc thất bại
check_status() {
    if [[ $? -eq 0 ]]; then
        echo "[+] $1 succeeded"
    else
        echo "[!] $1 failed"
        exit 1
    fi
}

# Kiểm tra quyền sudo
if ! sudo -l &>/dev/null; then
    echo "[!] This script requires sudo privileges"
    exit 1
fi
check_status "Sudo privilege check"

# Kiểm tra kết nối mạng
if ! ping -c 1 google.com &>/dev/null; then
    echo "[!] No internet connection"
    exit 1
fi
check_status "Internet connection check"

# Kiểm tra hệ điều hành
if ! grep -qi "ubuntu\|debian" /etc/os-release; then
    echo "[!] This script only supports Ubuntu/Debian-based systems"
    exit 1
fi
check_status "OS compatibility check"

# Kiểm tra apt
if ! command -v apt &>/dev/null; then
    echo "[!] apt packet not found"
    exit 1
fi
check_status "apt package check"

# Kiểm tra snap
if ! command -v snap &>/dev/null; then
    echo "[+] Installing snapd..."
    sudo apt-get install -y snapd &>/dev/null
    check_status "snapd installation"
fi

# Cập nhật và cài đặt gói
sudo apt-get -y update &>/dev/null
check_status "apt-get update"

sudo apt-get -y upgrade &>/dev/null
check_status "apt-get upgrade"

sudo apt-get install -y jq python3-pip &>/dev/null
check_status "jq and python3-pip installation"

# Cài đặt các gói cho wpscan
sudo apt-get install -y curl git libcurl4-openssl-dev make zlib1g-dev gawk g++ gcc libreadline6-dev libssl-dev libyaml-dev liblzma-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config ruby ruby-bundler ruby-dev libsqlite3-dev sqlite3 &>/dev/null
check_status "wpscan dependencies installation"

# Cài đặt các công cụ
sudo apt-get install -y sqlmap nmap &>/dev/null
check_status "sqlmap, nmap, awscli installation"

# Kiểm tra shell hiện tại
case "$SHELL" in
    */zsh) SHELL_CONFIG='.zshrc' ;;
    */bash) SHELL_CONFIG='.bashrc' ;;
    *) echo "[!] Unsupported shell: $SHELL. Defaulting to .bashrc"; SHELL_CONFIG='.bashrc' ;;
esac
check_status "Shell detection SHELL_CONFIG=${SHELL_CONFIG}"

# Cài đặt GoLang
if ! command -v go &>/dev/null; then
    curl -ks https://go.dev/dl/ -o dl.html

    arch=$(uname -m)
    case "$arch" in
        x86_64) filego=$(grep -Eo 'class="download downloadBox" href="(.+linux-amd64.tar.gz)"' dl.html | sed -E 's/class="download downloadBox" href="(.+)"/\1/' | head -n 1) ;;
        aarch64) filego=$(grep -Eo 'class="download downloadBox" href="(.+linux-arm64.tar.gz)"' dl.html | sed -E 's/class="download downloadBox" href="(.+)"/\1/' | head -n 1) ;;
        *) echo "[!] Unsupported architecture: $arch"; exit 1 ;;
    esac
    check_status "Architecture detection $arch"

    if [[ -z "$filego" ]]; then
        echo "[!] Failed to find GoLang download link"
        rm -f dl.html
        exit 1
    fi

    FILE_GO="$(echo $filego|sed 's/\/dl\///g')"
    LINK_DOWNLOAD="https://golang.org$filego"
    wget -q $LINK_DOWNLOAD 
    check_status "Downloading GoLang $LINK_DOWNLOAD"
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $FILE_GO &>/dev/null
    check_status "Extracting GoLang $FILE_GO"
    rm -f "$FILE_GO" dl.html
    check_status "Cleaning up GoLang download files"

    if ! grep -q 'export GOROOT="/usr/local/go"' "$HOME/$SHELL_CONFIG"; then
        echo 'export GOROOT="/usr/local/go"' >> "$HOME/$SHELL_CONFIG"
    fi
    if ! grep -q 'export GOPATH="$HOME/go"' "$HOME/$SHELL_CONFIG"; then
        echo 'export GOPATH="$HOME/go"' >> "$HOME/$SHELL_CONFIG"
    fi
    if ! grep -q 'export PATH="$PATH:$GOPATH/bin:$GOROOT/bin"' "$HOME/$SHELL_CONFIG"; then
        echo 'export PATH="$PATH:$GOPATH/bin:$GOROOT/bin"' >> "$HOME/$SHELL_CONFIG"
    fi
    export GOROOT="/usr/local/go"
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin:$GOROOT/bin"
    check_status "Setting GoLang environment variables"
else
    echo "[+] GoLang exists"
fi

# Chuyển đến thư mục tools
if [[ -d "$HOME/tools" ]]; then
		echo "[+] Tools directory already exists"
else
		mkdir -p "$HOME/tools" &>/dev/null
		check_status "Creating tools directory"
fi

cd "$HOME/tools" || { echo "[!] Failed to change to $HOME/tools"; exit 1; }
check_status "Changing to tools directory"

# Cài đặt Nuclei
if command -v nuclei &>/dev/null; then
    echo "[+] Nuclei already installed"
else
    echo 'Installing Nuclei'
    go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest &>/dev/null
    check_status "Nuclei installation"
    echo 'Updating Nuclei templates'
    nuclei -update-templates &>/dev/null
    check_status "Nuclei template update"
fi

# Cài đặt Httpx
if command -v httpx &>/dev/null; then
    echo "[+] Httpx already installed"
else
    echo 'Installing Httpx'
    go install github.com/projectdiscovery/httpx/cmd/httpx@latest &>/dev/null
    check_status "Httpx installation"
fi

# Cài đặt katana
if command -v katana &>/dev/null; then
    echo "[+] Katana already installed"
else
    echo 'Installing katana'
    CGO_ENABLED=1 go install github.com/projectdiscovery/katana/cmd/katana@latest &>/dev/null
    check_status "katana installation"
fi

# Cài đặt Subfinder
if command -v subfinder &>/dev/null; then
    echo "[+] Subfinder already installed"
else
    echo 'Installing Subfinder'
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &>/dev/null
    check_status "Subfinder installation"
fi

# Cài đặt Assetfinder
if command -v assetfinder &>/dev/null; then
    echo "[+] Assetfinder already installed"
else
    echo 'Installing Assetfinder'
    go install github.com/tomnomnom/assetfinder@latest &>/dev/null
    check_status "Assetfinder installation"
fi

# Cài đặt Waybackurls
if command -v waybackurls &>/dev/null; then
    echo "[+] Waybackurls already installed"
else
    echo 'Installing Waybackurls'
    go install github.com/tomnomnom/waybackurls@latest &>/dev/null
    check_status "Waybackurls installation"
fi

# Cài đặt Gf
if command -v gf &>/dev/null; then
    echo "[+] Gf already installed"
else
    echo 'Installing Gf'
    go install github.com/tomnomnom/gf@latest &>/dev/null
    check_status "Gf installation"
fi

# Tải Gf-Patterns
if [[ -d ~/.gf ]]; then
    echo "[+] Gf-Patterns already exists"
else
    echo 'Downloading Gf-Patterns'
    git clone https://github.com/1ndianl33t/Gf-Patterns.git &>/dev/null
    check_status "Cloning Gf-Patterns"
    mv Gf-Patterns ~/.gf &>/dev/null
    check_status "Moving Gf-Patterns to ~/.gf"
fi

# Cài đặt Subjack
if command -v subjack &>/dev/null; then
    echo "[+] Subjack already installed"
else
    echo 'Installing Subjack'
    go install github.com/haccer/subjack@latest &>/dev/null
    check_status "Subjack installation"
    git clone https://github.com/haccer/subjack.git &>/dev/null
    check_status "Cloning Subjack repository"
fi

# Cài đặt Chromium
if command -v chromium &>/dev/null; then
    echo "[+] Chromium already installed"
else
    echo 'Installing Chromium'
    sudo snap install chromium &>/dev/null
    check_status "Chromium installation"
fi

# Cài đặt Aquatone
if command -v aquatone &>/dev/null; then
    echo "[+] Aquatone already installed"
else
    echo 'Installing Aquatone'
    aquatone='aquatone_linux_amd64_1.7.0.zip'
    wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/$aquatone &>/dev/null
    check_status "Downloading Aquatone"
    unzip "$aquatone" &>/dev/null
    check_status "Unzipping Aquatone"
    rm -f README.md LICENSE.txt &>/dev/null
    check_status "Cleaning up Aquatone files"
    sudo mv aquatone /usr/local/bin/ &>/dev/null
    check_status "Moving Aquatone to /usr/local/bin"
fi

# Cài đặt Wpscan
if command -v wpscan &>/dev/null; then
    echo "[+] Wpscan already installed"
else
    echo 'Installing Wpscan'
    sudo gem install wpscan &>/dev/null
    check_status "Wpscan installation"
fi

# Cài đặt Dirsearch
if [[ -d ~/tools/dirsearch ]]; then
    echo "[+] Dirsearch already installed"
else
    cd ~/tools || { echo "[!] Failed to change to ~/tools"; exit 1; }
    echo 'Installing Dirsearch'
    git clone https://github.com/maurosoria/dirsearch.git &>/dev/null
    check_status "Cloning Dirsearch repository"
    cd ~/tools/dirsearch
    python3 -m pip install -r requirements.txt &>/dev/null
    check_status "Installing Dirsearch requirements"
    # Kiểm tra nếu alias đã tồn tại
    if grep -q "alias dirsearch=" "$HOME/$SHELL_CONFIG"; then
        echo "[+] Dirsearch alias already exists"
    else
        echo 'alias dirsearch="python3 ~/tools/dirsearch/dirsearch.py "' >> "$HOME/$SHELL_CONFIG"
        check_status "Adding Dirsearch alias to shell configuration"
    fi
fi

# Cài đặt Linkfinder
if [[ -d ~/tools/linkfinder ]]; then
    echo "[+] Linkfinder already installed"
else
    cd ~/tools || { echo "[!] Failed to change to ~/tools"; exit 1; }
    echo 'Installing Linkfinder'
    git clone https://github.com/GerbenJavado/LinkFinder.git linkfinder &>/dev/null
    check_status "Cloning Linkfinder repository"
    cd ~/tools/linkfinder || { echo "[!] Failed to change to ~/tools/linkfinder"; exit 1; }
    python3 -m pip install -r requirements.txt &>/dev/null
    check_status "Installing Linkfinder requirements"
    # Kiểm tra nếu alias đã tồn tại
    if grep -q "alias linkfinder=" "$HOME/$SHELL_CONFIG"; then
        echo "[+] Linkfinder alias already exists"
    else
        echo 'alias linkfinder="python3 ~/tools/linkfinder/linkfinder.py "' >> "$HOME/$SHELL_CONFIG"
        check_status "Adding Linkfinder alias to shell configuration"
    fi
fi

# Cài đặt SecretFinder
if [[ -d ~/tools/secretfinder ]]; then
    echo "[+] SecretFinder already installed"
else
    cd ~/tools || { echo "[!] Failed to change to ~/tools"; exit 1; }
    echo 'Installing SecretFinder'
    git clone https://github.com/m4ll0k/SecretFinder.git secretfinder &>/dev/null
    check_status "Cloning SecretFinder repository"
    cd ~/tools/secretfinder || { echo "[!] Failed to change to ~/tools/secretfinder"; exit 1; }
    python3 -m pip install -r requirements.txt &>/dev/null
    check_status "Installing SecretFinder requirements"
    # Kiểm tra nếu alias đã tồn tại
    if grep -q "alias secretfinder=" "$HOME/$SHELL_CONFIG"; then
        echo "[+] SecretFinder alias already exists"
    else
        echo 'alias secretfinder="python3 ~/tools/secretfinder/SecretFinder.py "' >> "$HOME/$SHELL_CONFIG"
        check_status "Adding SecretFinder alias to shell configuration"
    fi
fi

# Cài đặt Massdns
if command -v massdns &>/dev/null; then
    echo "[+] Massdns already installed"
else
    echo 'Installing Massdns'
    git clone https://github.com/blechschmidt/massdns.git &>/dev/null
    check_status "Cloning Massdns repository"
    cd ~/tools/massdns || { echo "[!] Failed to change to ~/tools/massdns"; exit 1; }
    make &>/dev/null
    check_status "Building Massdns"
    sudo cp ~/tools/massdns/bin/massdns /usr/local/bin/ &>/dev/null
    check_status "Installing Massdns to /usr/local/bin"
fi

# Cài đặt Masscan
if command -v masscan &>/dev/null; then
    echo "[+] Masscan already installed"
else
    echo 'Installing Masscan'
    cd ~/tools || { echo "[!] Failed to change to ~/tools"; exit 1; }
    git clone https://github.com/robertdavidgraham/masscan &>/dev/null
    check_status "Cloning Masscan repository"
    cd ~/tools/masscan || { echo "[!] Failed to change to ~/tools/masscan"; exit 1; }
    make &>/dev/null
    check_status "Building Masscan"
    sudo cp ~/tools/masscan/bin/masscan /usr/local/bin/ &>/dev/null
    check_status "Installing Masscan to /usr/local/bin"
fi

# Tải SecLists
if [[ -d ~/tools/SecLists ]]; then
    echo "[+] SecLists already installed"
else
    echo 'Downloading SecLists'
    cd ~/tools || { echo "[!] Failed to change to ~/tools"; exit 1; }
    git clone https://github.com/danielmiessler/SecLists.git &>/dev/null
    check_status "Cloning SecLists repository"
    cd ~/tools/SecLists/Discovery/DNS/ || { echo "[!] Failed to change to ~/tools/SecLists/Discovery/DNS"; exit 1; }
    cat dns-Jhaddix.txt | head -n -14 > clean-jhaddix-dns.txt &>/dev/null
    check_status "Cleaning dns-Jhaddix.txt"
fi

# Cài đặt Gitleaks
if command -v gitleaks &>/dev/null; then
    echo "[+] Gitleaks already installed"
else
    echo 'Installing Gitleaks'
    go install github.com/zricethezav/gitleaks/v8@latest &>/dev/null
    check_status "Gitleaks installation"
fi

# # Cài đặt Gitrob
# if command -v gitrob &>/dev/null; then
#     echo "[+] Gitrob already installed"
# else
#     echo 'Installing Gitrob'
#     go install github.com/michenriksen/gitrob@latest &>/dev/null
#     check_status "Gitrob installation"
# fi

# in ra thông tin cài đặt
echo "Installation completed successfully!"
# In ra câu lệnh source tệp cấu hình shell
echo "Please run the following command to apply changes:"
echo "source $HOME/$SHELL_CONFIG"

# In ra danh sách các công cụ đã cài đặt
echo "Installed tools:"
echo "- Nuclei"
echo "- Httpx"
echo "- Katana"
echo "- Subfinder"
echo "- Assetfinder"
echo "- Waybackurls"
echo "- Gf"
echo "- Subjack"
echo "- Chromium"
echo "- Aquatone"
echo "- Wpscan"
echo "- Dirsearch"
echo "- Linkfinder"
echo "- SecretFinder"
echo "- Massdns"
echo "- Masscan"
echo "- SecLists"
echo "- Gitleaks"
#echo "- Gitrob"
