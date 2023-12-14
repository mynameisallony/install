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
            whiptail --title "Instalación de CDN" --msgbox "Instalando $package..." 8 78
            apt-get install -y $package
            apt-get update
        else
            #echo "$package ya está instalado."
            whiptail --title "Instalación de CDN" --msgbox "$package ya está instalado." 8 78
        fi
    done

    # Verifica se o módulo bonding já está carregado
    if lsmod | grep -q "bonding"; then
        #echo "El módulo bonding ya está cargado."
        whiptail --title "Instalación de CDN" --msgbox "El módulo bonding ya está cargado." 8 78
    else
        # Carrega o módulo bonding
        modprobe bonding
        #echo "Módulo bonding cargado."
        whiptail --title "Instalación de CDN" --msgbox "Módulo bonding cargado." 8 78
    fi

    # Adiciona o módulo ao arquivo /etc/modules, se ainda não estiver presente
    if ! grep -q "bonding" /etc/modules; then
        echo "bonding" >> /etc/modules
        #echo "Módulo bonding agregado a /etc/modules."
        whiptail --title "Instalación de CDN" --msgbox "Módulo bonding agregado a /etc/modules." 8 78
    else
        echo "El módulo bonding ya está presente en el archivo /etc/modules."
        whiptail --title "Instalación de CDN" --msgbox "El módulo bonding ya está presente en el archivo /etc/modules.." 8 78
    fi

    # Verificação do driver bonding
    if modinfo bonding &> /dev/null; then
        echo "Instalação e verificação bem-sucedidas!"
    else
        echo "Erro na instalação ou verificação do driver bonding."
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
