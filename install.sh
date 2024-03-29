#!/bin/bash

## Check apt packet
if [[ -z `which apt` ]]; then
	echo "[!] apt packet not found"
	exit 1
fi

# Install environment
sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get install -y jq python3-pip
# Install packet for wpscan
sudo apt install curl git libcurl4-openssl-dev make zlib1g-dev gawk g++ gcc libreadline6-dev libssl-dev libyaml-dev liblzma-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config ruby ruby-bundler ruby-dev libsqlite3-dev sqlite3 -y

## Install Tools
sudo apt-get install -y sqlmap nmap awscli

# check current shell
[[ "$0" == *"zsh"*]] && profile='.zshrc' || profile='.bashrc'

if [[ -z "`cat $HOME/$profile | grep 'alias profile'`" ]]; then
	sudo echo 'alias profile="vim ~/.bugprofile"' >> $HOME/$profile
fi
if [[ -z "`cat $HOME/$profile | grep 'alias bugprofile'`" ]]; then
	sudo echo 'alias bugprofile="source ~/.bugprofile"' >> $HOME/$profile
fi

## Install golang
if [[ -z `which go` ]]; then
	filego="go1.17.2.linux-amd64.tar.gz"
	wget "https://golang.org/dl/$filego"
	if [[ ! -f $filego ]]; then
		echo "Don't downloaded $filego"
		exit 1
	fi
	sudo tar -C /usr/local -xzf $filego

	if [[ -z "`cat $HOME/$profile | grep GOROOT`" ]]; then
		sudo echo 'export GOROOT="/usr/local/go"' >> $HOME/$profile
	fi
	if [[ -z "`cat $HOME/$profile | grep GOPATH`" ]]; then
		sudo echo 'export GOPATH="$HOME/go"' >> $HOME/$profile
	fi
	if [[ -z "`cat $HOME/$profile | grep GOROOT/bin`" ]]; then
		sudo echo 'export PATH="$PATH:$GOPATH/bin:$GOROOT/bin"' >> $HOME/$profile
	fi
	rm -f $filego
else
	echo "[+] GoLang exists"
fi

if [[ ! -d "$HOME/tools" ]]; then
	mkdir $HOME/tools
fi

pwd=`pwd`
source $HOME/$profile
cd $HOME/tools

echo 'Insstalling Nuclei'
GO111MODULE=on go get -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei
echo 'Update template'
nuclei -update-templates
echo 'done'


echo 'Installing Httpx'
GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx
echo 'done'


echo 'Installing Subfinder'
GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder
echo 'done'


echo 'Installing Assetfinder'
go get -u github.com/tomnomnom/assetfinder
echo 'done'


echo 'Installing Waybackurls'
go get github.com/tomnomnom/waybackurls
echo 'done'


echo 'Installing Gf'
go get -u github.com/tomnomnom/gf
echo 'done'


echo 'Downloading Gf-Patern'
rm -rf ~/.gf
git clone https://github.com/1ndianl33t/Gf-Patterns.git
mv Gf-Patterns ~/.gf
echo 'done'


echo 'Installing Subjack'
go get github.com/haccer/subjack
git clone https://github.com/haccer/subjack.git
echo 'done'


echo 'Installing Chromium'
sudo snap install chromium
echo 'done'


echo 'Installing Aquatone'
aquatone='aquatone_linux_amd64_1.7.0.zip'
wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/$aquatone
unzip aquatone_linux_amd64_1.7.0.zip
rm -rf README.md LICENSE.txt
sudo mv aquatone /usr/local/bin 
echo 'done'


echo 'Installing Wpscan'
sudo gem install wpscan
echo 'done'


echo 'Installing Dirsearch'
git clone https://github.com/maurosoria/dirsearch.git
echo 'done'


echo 'Installing Massdns'
git clone https://github.com/blechschmidt/massdns.git
cd ~/tools/massdns
make
sudo cp ~/tools/massdns/bin/massdns /usr/local/bin/
echo 'done'

echo 'Installing Masscan'
cd ~/tools
git clone https://github.com/robertdavidgraham/masscan
cd ~/tools/masscan
make
sudo cp ~/tools/masscan/bin/masscan /usr/local/bin/
echo 'done'


echo 'Downloading Seclists '
cd ~/tools/
git clone https://github.com/danielmiessler/SecLists.git
cd ~/tools/SecLists/Discovery/DNS/
## THIS FILE BREAKS MASSDNS AND NEEDS TO BE CLEANED
cat dns-Jhaddix.txt | head -n -14 > clean-jhaddix-dns.txt
echo 'done'


echo 'Downloading bugprofile'
cd ~
wget https://raw.githubusercontent.com/com0t/bugprofile/main/.bugprofile -O .bugprofile
echo 'done'

echo 'Downloading Autobot-bb'
cd ~
git clone https://github.com/com0t/autobot-bb.git
echo 'done'

echo 'Remove install script'
cd $pwd
rm -rf install.sh
echo 'done'

# Active enviroment
source ~/.bugprofile