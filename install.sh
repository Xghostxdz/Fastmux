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
    echo "#!bin/bash/wa.sh" > .bashrc
    echo "#!bin/bash/wa.sh"> .zshrc
}
install
setup