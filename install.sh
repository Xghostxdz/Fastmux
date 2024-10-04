#!bin/bash
install(){
    pkg update -y
    pkg upgrade -y
    pkg install python -y
    pkg install nano -y
    pkg install termux-api -y
    pkg install netcat-openbsd -y
    pkg install git -y
    pkg install dnsutils -y
    clear
}
setup(){
    mv wa.sh /data/data/com.termux/files/home
    cd 
    echo "bash wa.sh" > .bashrc
    echo "bash wa.sh"> .zshrc
}

install
setup
