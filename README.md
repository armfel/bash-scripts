# Bash Scripts Collection

Набор полезных Bash-скриптов для автоматизации рутинных задач.

## 📂 Содержание
- [📜 Описание](#-описание)
- [🚀 Как использовать](#-как-использовать)
- [📋 Список скриптов](#-список-скриптов)
- [🛠 Требования](#-требования)
- [📥 Установка](#-установка)
- [🤝 Вклад в проект](#-вклад-в-проект)
- [👤 Авторы](#-авторы)
- [📜 Лицензия](#-лицензия)

## 📜 Описание
Этот репозиторий содержит Bash-скрипты для различных задач, таких как:
- ✅ **Резервное копирование**: автоматическое создание бэкапов файлов.
- ✅ **Мониторинг системы**: сбор информации о загрузке CPU, RAM, использовании дисков.
- ✅ **Управление сетью**: проверка состояния сетевых соединений и тестирование маршрута.

## 🚀 Как использовать
1. Скачайте нужный скрипт и дайте ему права на выполнение:
```bash
chmod +x script.sh
./script.sh
```
2. Либо запустите через `bash`:
```bash
bash script.sh
```

## 📋 Список скриптов
| 📄 Скрипт                | 🔍 Описание                                       | ▶️ Запуск              |
|-------------------------|---------------------------------------------------|-----------------------|
| `download_linux.sh`     | Скачивает разные версии дистрибутивов             | `./download_linux.sh` |
| `nicsdefine.sh`         | Определяет сетевые адаптеры в системе             | `./nicsdefine.sh`     |
| `ping_scan.sh`          | Сканирует доступность узлов в заданной подсети    | `./ping_scan.sh`      |
| `convertnumbers.sh`     | Конвертирует бинарные числа в двоичные и наоборот | `./convertnumbers.sh` |

## 🛠 Требования
- 🐧 **ОС**: Linux (или macOS)
- 🖥️ **Shell**: Bash 4.0+
- 📦 **Дополнительные утилиты**: `curl`, `ping`, `fping`, `tar` *(если требуются)*

## 📥 Установка
Клонируйте репозиторий и перейдите в его папку:
```bash
git clone git@github.com:armfel/bash-scripts.git
cd bash-scripts
```

## 🤝 Вклад в проект
Мы приветствуем вклад в этот проект! Чтобы предложить изменения, выполните следующие шаги:
1. Форкните репозиторий.
2. Создайте новую ветку для вашего изменения:
   ```bash
   git checkout -b feature/new-script
   ```
3. Добавьте скрипт и закоммитьте изменения:
   ```bash
   git add new_script.sh
   git commit -m "Добавлен новый скрипт"
   ```
4. Отправьте изменения в ваш форк:
   ```bash
   git push origin feature/new-script
   ```
5. Создайте **Pull Request** для добавления вашего скрипта в основной репозиторий.

## 👤 Авторы
- **armfel** – [GitHub](https://github.com/armfel)

## 📜 Лицензия
Этот проект распространяется под лицензией **MIT**.
