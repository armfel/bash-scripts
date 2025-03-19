#!/usr/bin/env bash

# Определение цветов
RED="\033[0;31m"
CYAN="\033[0;36m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CLEAR="\033[0m"

# Проверка наличия fping в системе
if ! command -v fping &>/dev/null; then
    echo -e "${RED}Ошибка: fping не установлен. Установите его и повторите попытку.${CLEAR}"
    exit 1
fi

# Проверка наличия аргумента
if [[ -z "${1}" ]]
then
	echo -e "${YELLOW}Использование: $0 <CIDR-сеть>, например, 192.168.1.0/24 10.0.0.0/16 172.16.0.0/12${CLEAR}"
	exit 1
fi

# Проверка на валидность ip и маски
validate_cidr() {
	local CIDR="${1}"
	if ! echo "${CIDR}" | grep -Pq "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]?|0)\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]?|0)\/([0-9]|1[0-9]|2[0-9]|3[0-2])$"
	then
		return 1
	fi
	return 0
}

# Функция для преобразования IP в число
ip_to_int() {
	local IFS='/.'
    	local IP="${1}"
	local OCTETS
	read -r -a OCTETS <<< "${IP%%/*}"
    	echo "$(((OCTETS[0] << 24) | (OCTETS[1] << 16) | (OCTETS[2] << 8) | OCTETS[3]))"
	return 0
}

# Функция для преобразования числа в IP
int_to_ip() {
	local IP="${1}"
	echo "$(((IP >> 24) & 255)).$(((IP >> 16) & 255)).$(((IP >> 8) & 255)).$((IP & 255))"
	return 0
}

scan_network() {
	# Ограничение количества параллельных процессов
	local MAX_PROCS=32
	local SEMAPHORE="/tmp/scan_semaphore.$$"
	local VALID_FOUND=0

	while [[ "${#}" -gt 0 ]]
	do
		local CIDR="${1}"
		shift

		if ! validate_cidr "${CIDR}"
		then
			echo -e "${RED}Ошибка: Неверный CIDR '${CIDR}', пропускаю...${CLEAR}" >&2
			continue
		else
			VALID_FOUND=1
		fi

		# Получаем сеть и маску
		local NETWORK="$(echo ${CIDR} | cut -d '/' -f 1)"
		local PREFIX="$(echo ${CIDR} | cut -d '/' -f 2)"

		# Вычисляем начальный и конечный IP
		local NETWORK_INT="$(ip_to_int ${NETWORK})"
		local MASK="$((0xFFFFFFFF << (32 - PREFIX) & 0xFFFFFFFF))"
		local NETWORK_INT="$((NETWORK_INT & MASK))"
		local BROADCAST_INT="$((NETWORK_INT | ~MASK & 0xFFFFFFFF ))"

		# Начинаем сканирование (исключаем network и broadcast)
		echo -e "${CYAN}Сканирование сети ${CIDR}...${CLEAR}"
		for ((IP=NETWORK_INT+1; IP<BROADCAST_INT; IP++))
		do
			TARGET="$(int_to_ip ${IP})"

			# Ожидаем, если запущено больше процессов, чем MAX_PROCS
			while [[ "$(jobs | wc -l)" -ge "${MAX_PROCS}" ]]
			do
				sleep 0.1
			done

			# Семафор для управления параллельными процессами
            		touch "${SEMAPHORE}"

			# Запускаем процесс сканирования
			fping -c 5 -t 200 "${TARGET}" &>/dev/null && echo -e "${GREEN}${TARGET} доступен${CLEAR}" &

			# Удаляем семафор после завершения проверки
			rm -f "${SEMAPHORE}"
		done

		# Дождаться завершения всех фонов процессов
		wait

		echo -e "${CYAN}Сканирование сети ${CIDR} завершено.${CLEAR}"
	done

	# После завершения цикла обработки всех CIDR
	if [[ "${VALID_FOUND}" -eq 0 ]]
	then
    		echo -e "${RED}Нет валидных CIDR для сканирования.${CLEAR}" >&2
    		exit 1
	fi

	return 0
}

scan_network "${@}"

exit 0
