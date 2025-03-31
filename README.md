# Режим киоска для Ubuntu Server Minimal

Этот скрипт автоматизирует настройку Ubuntu Server Minimal в режим киоска с анимацией загрузки. Скрипт выполняет следующие задачи:

- Устанавливает необходимые пакеты (X-сервер, Openbox, Chromium, Plymouth и др.).
- Создаёт пользователя `kiosk` (если он ещё не существует) с автоматическим входом.
- Настраивает автозапуск Openbox, который запускает браузер Chromium в полноэкранном (киоск) режиме, открывая заданный URL.
- Позволяет условно установить утилиту `unclutter` для скрытия курсора.
- Настраивает Plymouth для анимации загрузки, включая установку и конфигурацию темы.

## Возможности

- **Автоматическая настройка**: Скрипт проверяет наличие пользователя, обновляет систему, устанавливает нужные пакеты и настраивает автоматический вход.
- **Опция установки unclutter**: Возможность выбора установки `unclutter` для скрытия курсора.
- **Логирование**: Скрипт выводит отметки времени и сообщения о прогрессе выполнения, что помогает в отладке.
- **Настройка анимации загрузки**: Конфигурирование Plymouth для показа анимированной заставки при загрузке системы.

## Требования

- Ubuntu Server Minimal (или совместимая система на базе Ubuntu).
- Доступ к `sudo`.

## Установка

1. Склонируйте репозиторий:
   ```bash
   git clone https://github.com/Riv33R/kiosk.git
   cd kiosk
   ```

2. Сделайте скрипт исполняемым:
   ```bash
   chmod +x kiosk.sh
   ```

3. Запустите скрипт:
   ```bash
   sudo ./kiosk.sh
   ```

   **Примечание:** Скрипт выполнит обновление системы, установку необходимых пакетов и настройку параметров. После завершения он перезагрузит систему.

## Настройка

- **URL для киоска**  
  В ходе выполнения скрипта будет предложено задать нужный URL адрес

- **Plymouth Theme**  
  Скрипт настраивает тему Plymouth, перезаписывая конфигурационный файл `/usr/share/plymouth/themes/default.plymouth` с заданными параметрами. При необходимости измените параметры темы в скрипте.

## Логирование

Скрипт использует функцию `log()`, которая выводит сообщения с отметкой времени для каждого этапа выполнения. Это позволяет отслеживать ход работы скрипта и диагностировать возможные ошибки.

## Предостережения

- Скрипт **перезагружает систему** после завершения настройки, поэтому убедитесь, что на сервере можно произвести перезагрузку.
- Рекомендуется протестировать скрипт в тестовой среде перед развёртыванием на рабочей системе.
- Если пользователь `kiosk` уже существует, скрипт пропустит его создание.

## Вклад

Если у вас есть предложения по улучшению или обнаружены ошибки, пожалуйста, создайте issue или отправьте pull request.

## Лицензия

Этот проект распространяется под [MIT License](LICENSE).
