#!/bin/bash

# color code
B="\033[1;30m"   # Black
R="\033[1;31m"   # Red
G="\033[1;32m"   # Green
Y="\033[1;33m"   # Yellow
Bl="\033[1;34m"  # Blue
P="\033[1;35m"   # Purple
C="\033[1;36m"   # Cyan
W="\033[1;37m"   # White
RESET='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
g0="\033[1;32m"   # أخضر
r="\033[1;31m"    # أحمر

LOGFILE="activity_log.txt"  # ملف السجل

# دالة لطباعة النص مع تأثير الكتابة
typing_effect() {
    text="$1"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.05
    done
    echo ""
}

# دالة لتسجيل النشاطات
log_activity() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${USER} - $1" >> "$LOGFILE"
}

# دالة لتسجيل الأخطاء
log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $1" >> "$LOGFILE"
}

# دالة لإرسال إشعارات
send_notification() {
    termux-notification --title "$1" --content "$2"
}

# دالة لتحديث الحزم وتثبيت الأدوات
update_packages() {
    pkg update && pkg upgrade -y
    log_activity "Packages updated"
}

install_tools() {
    pkg install -y curl wget net-tools dnsutils
    log_activity "Installed tools: curl, wget, net-tools, dnsutils"
}

# دالة لإدارة الحزم
install_package() {
    echo "Enter package name to install:"
    read package
    pkg install -y "$package"
    log_activity "Installed package: $package"
}

remove_package() {
    echo "Enter package name to remove:"
    read package
    pkg uninstall -y "$package"
    log_activity "Removed package: $package"
}

# دالة لعرض حالة الشبكة
network_status() {
    ifconfig
    log_activity "Displayed network status"
}

# دالة لتنظيف الملفات المؤقتة
clean_temp_files() {
    echo "Cleaning temporary files..."
    rm -rf /data/data/com.termux/files/usr/tmp/*
    log_activity "Cleaned temporary files"
}

# دالة لفحص سلامة الروابط والمواقع
check_url_safety() {
    echo -e "${BLUE}Enter URL to check:${RESET}"
    read url
    status_code=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "$url")
    if [ "$status_code" -eq 200 ]; then
        echo -e "${GREEN}The URL is accessible and safe!${RESET}"
        log_activity "Checked URL: $url (Status: $status_code - Safe)"
    else
        echo -e "${RED}The URL is not accessible or might be unsafe! (Status: $status_code)${RESET}"
        log_error "Checked URL: $url (Status: $status_code - Unsafe)"
        send_notification "URL Check" "URL $url is not accessible or might be unsafe. Status Code: $status_code"
    fi
}

# دالة لفحص DNS
check_dns() {
    echo -e "${BLUE}Enter URL to check DNS records:${RESET}"
    read url
    domain=$(echo "$url" | awk -F[/:] '{print $4}')
    dig "$domain" +short
}

# دالة للتحقق من المنفذ
check_port() {
    echo -e "${BLUE}Enter host to check:${RESET}"
    read host
    echo -e "${BLUE}Enter port to check:${RESET}"
    read port
    nc -zv "$host" "$port" 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Port $port on $host is open.${RESET}"
        log_activity "Checked port $port on $host - Open"
    else
        echo -e "${RED}Port $port on $host is closed or inaccessible.${RESET}"
        log_error "Checked port $port on $host - Closed/ inaccessible"
        send_notification "Port Check" "Port $port on $host is closed or inaccessible."
    fi
}

# دالة للتحقق من إدخال المستخدم
chekuser() {
    echo -e "${BLUE}Enter your code:${RESET}"
    read pss
    filename="$pss"
    
    if [ -e "$filename" ]; then
        echo -e "${GREEN}"
        typing_effect "Login successfully"
        echo -e "${RESET}"
        clear
        while true; do  
            shell_command "$filename"  # تمرير اسم الملف إلى دالة موجه الأوامر
        done
    else
        echo -e "${RED}"
        typing_effect "Wrong code. Creating a new code..."
        echo -e "${RESET}"
        touch "$filename" 
        echo -e "${GREEN}Code '$filename' created successfully.${RESET}"
        while true; do
            shell_command "$filename"  # استدعاء دالة موجه الأوامر بعد إنشاء الملف
        done
    fi
}

# دالة لعرض موجه الأوامر مع اسم الملف
shell_command() {
    created_file="$1"
    svd=$(basename "$(pwd)")
    o="${g0}┌── (${r}${created_file}${g0})${g0} ~${P}${svd}${Y} ${g0}\n└─${R}$ ${W}"

    read -p "$(echo -e "$o")" user_input
    log_activity "$user_input"

    case "$user_input" in
        "Dns")
            check_dns
            ;;
        "CheckURL")
            check_url_safety
            ;;
        "CheckPort")
            check_port
            ;;
        "Update")
            update_packages
            ;;
        "InstallTools")
            install_tools
            ;;
        "InstallPackage")
            install_package
            ;;
        "RemovePackage")
            remove_package
            ;;
        "NetworkStatus")
            network_status
            ;;
        "CleanTemp")
            clean_temp_files
            ;;
        "Exit")
            close_termux
            ;;
        *)
            eval "$user_input"
            ;;
    esac
}

# استدعاء دالة التحقق من المستخدم
chekuser
