#!/bin/bash

set -e  # Прерывать выполнение при ошибках

# Функция логирования
log() {
    echo "[ $(date +'%Y-%m-%d %H:%M:%S') ] $*"
}

# Запрос значений у пользователя
read -p "Введите URL для киоска (по умолчанию https://example.com): " input_url
URL=${input_url:-"https://example.com"}

read -p "Устанавливать unclutter для скрытия курсора? (y/n, по умолчанию y): " input_unclutter
if [[ "$input_unclutter" =~ ^[Nn]$ ]]; then
    INSTALL_UNCLUTTER=false
else
    INSTALL_UNCLUTTER=true
fi

# Обновляем список пакетов
log "Обновляем список пакетов..."
sudo apt update

# Устанавливаем необходимые пакеты
PACKAGES="xserver-xorg x11-xserver-utils xinit openbox chromium-browser plymouth plymouth-theme-*"
log "Устанавливаем пакеты: $PACKAGES"
sudo apt install -y $PACKAGES

if [ "$INSTALL_UNCLUTTER" = true ]; then
    log "Устанавливаем unclutter для скрытия курсора..."
    sudo apt install -y unclutter
fi

# Создаём пользователя kiosk, если его ещё нет
if id "kiosk" &>/dev/null; then
    log "Пользователь 'kiosk' уже существует. Пропускаем создание."
else
    log "Создаём пользователя 'kiosk'..."
    sudo adduser --disabled-password --gecos "" kiosk
    sudo usermod -aG sudo kiosk
fi

# Настраиваем авто-вход
log "Настраиваем авто-вход для пользователя 'kiosk'..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo bash -c 'cat > /etc/systemd/system/getty@tty1.service.d/override.conf' <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin kiosk --noclear %I \$TERM
EOF

# Настраиваем Openbox и автозапуск браузера для пользователя kiosk
log "Настраиваем Openbox и автозапуск браузера для 'kiosk'..."
sudo -u kiosk mkdir -p /home/kiosk/.config/openbox
sudo -u kiosk bash -c 'cat > /home/kiosk/.config/openbox/autostart' <<EOF
#!/bin/bash
xset -dpms       # Отключить энергосбережение
xset s off       # Отключить скринсейвер
xset s noblank   # Отключить затемнение экрана
if [ "$INSTALL_UNCLUTTER" = true ]; then
    unclutter -idle 0.1 -root &  # Скрыть курсор
fi
chromium-browser --kiosk --disable-infobars --noerrdialogs --incognito "$URL" &
EOF
sudo chmod +x /home/kiosk/.config/openbox/autostart

# Настраиваем автозапуск X-сервера для пользователя kiosk
log "Настраиваем автозапуск X-сервера для 'kiosk'..."
sudo -u kiosk bash -c 'cat > /home/kiosk/.bash_profile' <<EOF
if [[ -z \$DISPLAY ]] && [[ \$(tty) == /dev/tty1 ]]; then
    startx
fi
EOF

# Настраиваем Plymouth и скрытие текста загрузки
log "Настраиваем анимацию загрузки (Plymouth)..."
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash vt.global_cursor_default=0"/' /etc/default/grub
sudo update-grub

# Настраиваем тему Plymouth
log "Настраиваем тему Plymouth..."
sudo update-alternatives --install /usr/share/plymouth/themes/glow.plymouth default.plymouth /usr/share/plymouth/themes/glow/glow.plymouth 1

log "Обновляем конфигурацию Plymouth..."
sudo bash -c 'cat > /usr/share/plymouth/themes/default.plymouth' <<EOF
TitleHorizontalAlignment=.5
TitleVerticalAlignment=.382
HorizontalAlignment=.5
VerticalAlignment=.7
WatermarkHorizontalAlignment=.5
WatermarkVerticalAlignment=.96
Transition=none
TransitionDuration=0.0
BackgroundStartColor=0x000000
BackgroundEndColor=0x000000
ProgressBarBackgroundColor=0x606060
ProgressBarForegroundColor=0xffffff
MessageBelowAnimation=true

[boot-up]
UseEndAnimation=false

[shutdown]
UseEndAnimation=false

[reboot]
UseEndAnimation=false

[updates]
SuppressMessages=true
ProgressBarShowPercentComplete=true
UseProgressBar=true
Title=Installing Updates...
SubTitle=Do not turn off your computer

[system-upgrade]
SuppressMessages=true
ProgressBarShowPercentComplete=true
UseProgressBar=true
Title=Upgrading System...
SubTitle=Do not turn off your computer

[firmware-upgrade]
SuppressMessages=true
ProgressBarShowPercentComplete=true
UseProgressBar=true
Title=Upgrading Firmware...
SubTitle=Do not turn off your computer
EOF

# Обновляем initramfs
log "Обновляем initramfs..."
sudo update-initramfs -u

# Завершаем настройку и перезагружаем систему
log "Настройка завершена. Перезагружаем систему..."
sudo reboot
