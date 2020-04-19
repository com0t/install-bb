# Install environment
## Check apt packet
if [[ -z `which apt` ]]; then
	echo "[!] apt packet not found"
	exit 0
fi
## Install golang
cd $HOME
if [[ -z `which go` ]]; then
	filego="go1.14.2.linux-amd64.tar.gz"
	wget "https://dl.google.com/go/$filego"
	if [[ ! -f $filego ]]; then
		echo "Don't downloaded $filego"
		exit 0
	fi
	if [[ ! -f "$HOME/.profile" ]]; then
		touch $HOME/.profile
	fi
	sudo tar -C /usr/local -xzf $filego
	sudo echo "export GOROOT=/usr/local/go" >> $HOME/.profile
	sudo echo "export GOPATH=$HOME/go" >> $HOME/.profile
	sudo echo "export PATH=$PATH:$GOPATH/bin:$GOROOT/bin" >> $HOME/.profile
	source $HOME/.profile
	rm -f $filego
else
	echo "[+] GoLang exists"
fi

# Install tool
if [[ -z `which git` ]]; then
	sudo apt install -y git
else
	echo "[+] Git exists"
fi

if [[ ! -d "$HOME/tools" ]]; then
	mkdir $HOME/tools
else
	echo "[+] tools folder exists"
fi

cd $HOME/tools
## Install dirsearch
echo "[+] Install dirsearch"
git clone https://github.com/maurosoria/dirsearch.git
sed -i 's,/usr/bin/env python3,'"`which python3`," dirsearch/dirsearch.py
echo "Create sym link dirsearch"
sudo ln -s $HOME/tools/dirsearch/dirsearch.py /usr/local/bin
## Install sqlmap
echo "[+] Install sqlmap"
sudo apt install -y sqlmap
## Install nmap
echo "[+] Install nmap"
sudo apt install -y nmap
## Install amass
echo "[+] Install amass"
sudo snap install amass
## Install assetfinder
echo "[+] Install assetfinder"
go get -u github.com/tomnomnom/assetfinder
## Install httprobe
echo "[+] Install httprobe"
go get -u github.com/tomnomnom/httprobe