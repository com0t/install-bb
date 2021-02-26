#!/bin/bash

## Check apt packet
if [[ -z `which apt` ]]; then
	echo "[!] apt packet not found"
	exit 1
fi

# Install environment
sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get install -y libcurl4-openssl-dev
sudo apt-get install -y libssl-dev
sudo apt-get install -y jq
sudo apt-get install -y ruby-full ruby
sudo apt-get install -y libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev build-essential libgmp-dev zlib1g-dev
sudo apt-get install -y build-essential libssl-dev libffi-dev python-dev
sudo apt-get install -y python-setuptools
sudo apt-get install -y libldns-dev
sudo apt-get install -y python3-pip
sudo apt-get install -y python-pip
sudo apt-get install -y python-dnspython
sudo apt-get install -y git
sudo apt-get install -y rename
sudo apt-get install -y xargs

## Install Tools
sudo apt-get install -y sqlmap nmap awscli


## Install golang
if [[ -z `which go` ]]; then
	filego="go1.16.linux-amd64.tar.gz"
	wget "https://dl.google.com/go/$filego"
	if [[ ! -f $filego ]]; then
		echo "Don't downloaded $filego"
		exit 1
	fi
	sudo tar -C /usr/local -xzf $filego

	if [[ -z "`cat $HOME/.profile | grep GOROOT`" ]]; then
		sudo echo 'export GOROOT="/usr/local/go"' >> $HOME/.profile
	fi
	if [[ -z "`cat $HOME/.profile | grep GOPATH`" ]]; then
		sudo echo 'export GOPATH="$HOME/go"' >> $HOME/.profile
	fi
	if [[ -z "`cat $HOME/.profile | grep GOROOT/bin`" ]]; then
		sudo echo 'export PATH="$PATH:$GOPATH/bin:$GOROOT/bin"' >> $HOME/.profile
	fi
	rm -f $filego
else
	echo "[+] GoLang exists"
fi

if [[ ! -d "$HOME/tools" ]]; then
	mkdir $HOME/tools
fi

source $HOME/.profile
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
echo 'Install Gf-Patern'
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
go get github.com/michenriksen/aquatone
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
echo'done'


echo 'Downloading Seclists '
cd ~/tools/
git clone https://github.com/danielmiessler/SecLists.git
cd ~/tools/SecLists/Discovery/DNS/
## THIS FILE BREAKS MASSDNS AND NEEDS TO BE CLEANED
cat dns-Jhaddix.txt | head -n -14 > clean-jhaddix-dns.txt
echo 'done'
