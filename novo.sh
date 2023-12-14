#!/usr/bin/env bash

instalarCdn() {

    HOSTNAME=$(whiptail --inputbox "Introduzca el nombre del servidor" 8 78 --title "Instalación de CDN" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            hostnamectl set-hostname --static $HOSTNAME 
        else
            exit
        fi
    # Verifica se o programa já está instalado
    check_installed() {
        dpkg -l | grep -q $1 > /dev/null 2>&1
    }

    # Verifica se o apt está instalado
    if ! check_installed apt; then
        #echo "O apt não está instalado. Este script suporta sistemas que usam apt para gerenciamento de pacotes."
        whiptail --title "Instalación de CDN" --msgbox "El APT no está instalado. Este script es compatible con sistemas que utilizan apt para la gestión de paquetes." 8 78
        exit 1
    fi

    # Verifica e instala as ferramentas
    packages=("ifenslave" "net-tools" "mtr" "nmap" "vim" "ipmitool" "ethtool")

    for package in "${packages[@]}"; do
        if ! check_installed $package; then
            #echo "Instalando $package..."
            TERM=ansi whiptail --title "Instalación de CDN" --infobox "Instalando $package..." 8 78
            sleep 2
            apt-get install -y $package
            sleep 2
        else
            #echo "$package ya está instalado."
            sleep 1
            TERM=ansi whiptail --title "Instalación de CDN" --infobox "$package ya está instalado." 8 78
        fi
    done

    # Verifica se o módulo bonding já está carregado
    sleep 1
    apt-get update
    if lsmod | grep -q "bonding"; then
        sleep 2
        TERM=ansi whiptail --title "Instalación de CDN" --infobox "El módulo bonding ya está cargado." 8 78
    else
        # Carrega o módulo bonding
        modprobe bonding
        sleep 2
        TERM=ansi whiptail --title "Instalación de CDN" --infobox "Módulo bonding cargado." 8 78
    fi

    # Adiciona o módulo ao arquivo /etc/modules, se ainda não estiver presente
    sleep 1
    if ! grep -q "bonding" /etc/modules; then
        echo "bonding" >> /etc/modules
        TERM=ansi whiptail --title "Instalación de CDN" --infobox "Módulo bonding agregado a /etc/modules." 8 78
    else
        TERM=ansi whiptail --title "Instalación de CDN" --infobox "El módulo bonding ya está presente en el archivo /etc/modules.." 8 78
    fi
    if (whiptail --title "Instalación de CDN" --yesno "¿Configurar interface bonding?" 8 78); then
        
        BOND=$(whiptail --inputbox "introduzca el nombre de la bond" 8 78 --title "Instalación de CDN" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            echo "" >> /etc/network/interfaces
            echo "auto $BOND" >> /etc/network/interfaces
            echo "iface $BOND inet manual" >> /etc/network/interfaces
            echo "  bond-slave none" >> /etc/network/interfaces
            echo "  bond-mode 4" >> /etc/network/interfaces
            echo "  bond-miimon 100" >> /etc/network/interfaces
            echo "  bond-downdelay 200" >> /etc/network/interfaces
            echo "  bond-lacprate 100" >> /etc/network/interfaces
            echo "  bond-xmit-hash-policy layer3+4" >> /etc/network/interfaces
            echo "" >> /etc/network/interfaces
        else
            exit
        fi



    else
        echo "User selected No, exit status was $?."
    fi
}

instalarEncoderNetint() {
    echo "Opção NETINT"
}

instalarEncoderTesla() {
    echo "Opção TESLA"
}

exibirMenu() {
    while true; do
        opcao=$(whiptail --title "Instalación de Servicios" --menu "Elija una de las siguientes opciones" 15 50 4 \
            "1" "Instalar CDN" \
            "2" "Instalar ENCODER NETINT" \
            "3" "Instalar ENCODER TESLA" \
            "4" "Sair" 3>&1 1>&2 2>&3)

        status=$?
        if [ $status = 0 ]; then
            case $opcao in
            1) instalarCdn ;;
            2) instalarEncoderNetint ;;
            3) instalarEncoderTesla ;;
            4) exit ;;
            esac
        else
            #echo "Opção cancelada."
            exit
        fi

    done
}
exibirMenu
