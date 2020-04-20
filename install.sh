# Install environment
## Check apt packet
if [[ -z `which apt` ]]; then
	echo "[!] apt packet not found" | tee >> install-bb.log
	exit 0
fi
## Install golang
cd $HOME
if [[ -z `which go` ]]; then
	filego="go1.14.2.linux-amd64.tar.gz"
	wget "https://dl.google.com/go/$filego"
	if [[ ! -f $filego ]]; then
		echo "Don't downloaded $filego" | tee >> install-bb.log
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
	echo "[+] GoLang exists" | tee >> install-bb.log
fi
## Install pip3 and pip
if [[ -z `which pip3` ]]; then
	sudo apt install -y python3-pip
else
	echo "[+] pip3 exists" | tee >> install-bb.log
fi
if [[ -z `which pip` ]]; then
	sudo apt install -y python-pip
else
	echo "[+] pip exists" | tee >> install-bb.log
fi
# Install tool
if [[ -z `which git` ]]; then
	sudo apt install -y git
else
	echo "[+] Git exists" | tee >> install-bb.log
fi

if [[ ! -d "$HOME/tools" ]]; then
	mkdir $HOME/tools
else
	echo "[+] tools folder exists" | tee >> install-bb.log
fi

cd $HOME/tools
## Install dirsearch
if [[ -z `which dirsearch` ]]; then
	echo "[+] Install dirsearch" | tee >> install-bb.log
	git clone https://github.com/maurosoria/dirsearch.git
	sed -i 's,/usr/bin/env python3,'"`which python3`," dirsearch/dirsearch.py
	echo "Create sym link dirsearch" | tee >> install-bb.log
	sudo ln -s $HOME/tools/dirsearch/dirsearch.py /usr/local/bin/dirsearch
else
	echo "[+] dirsearch exists" | tee >> install-bb.log
fi
## Install sqlmap
if [[ -z `which sqlmap` ]];then
	echo "[+] Install sqlmap" | tee >> install-bb.log
	sudo apt install -y sqlmap
else
	echo "[+] sqlmap exists" | tee >> install-bb.log
fi
## Install nmap
if [[ -z `which nmap` ]]; then
	echo "[+] Install nmap" | tee >> install-bb.log
	sudo apt install -y nmap
else
	echo "[+] nmap exists" | tee >> install-bb.log
fi
## Install amass
if [[ -z `which amass` ]]; then
	echo "[+] Install amass" | tee >> install-bb.log
	sudo snap install amass
else
	echo "[+] amass exists" | tee >> install-bb.log
fi
## Install assetfinder
if [[ -z `which assetfinder` ]]; then
	echo "[+] Install assetfinder" | tee >> install-bb.log
	go get -u github.com/tomnomnom/assetfinder
else
	echo "[+] assetfinder exists" | tee >> install-bb.log
fi
## Install httprobe
if [[ -z `which httprobe` ]]; then
	echo "[+] Install httprobe" | tee >> install-bb.log
	go get -u github.com/tomnomnom/httprobe
else
	echo "[+] httprobe exists" | tee >> install-bb.log
fi
## Install paramspider
if [[ -z `which paramspider` ]]; then
	echo '[+] Install paramspider' | tee >> install-bb.log
	git clone https://github.com/devanshbatham/ParamSpider
	cd ParamSpider
	pip3 install -r requirements.txt
	sed -i '1s,^,'"`which python3`"'\n,' paramspider.py
	chmod +x paramspider.py
	sudo ln -s $HOME/tools/ParamSpider/paramspider.py /usr/local/bin/paramspider
	cd ..
else
	echo "[+] paramspider exists" | tee >> install-bb.log
fi