#!/usr/bin/env bash

# Функция для перевода двоичного числа в десятичное
binary_to_decimal() {
	echo "$((2#${1}))"
}

# Функция для перевода десятичного числа в двоичное
decimal_to_binary() {
	echo "obase=2;${1}" | bc
}

PS3="Choose option: "
OPTIONS=("Convert binary to decimal" "Convert decimal to binary" "Quit")
select OPT in "${OPTIONS[@]}"
do
	case "${OPT}" in
		"Convert binary to decimal")
			while [[ true ]]
			do
				read -p "Please input binary number: " BINARY
				if [[ "${BINARY}" =~ ^[01]+$ ]]
				then
        				echo "Decimal number: $(binary_to_decimal ${BINARY})"
					break
				else
					echo "Invalid input binary number!" >&2
					continue
				fi
			done
			;;
		"Convert decimal to binary")
			while [[ true ]]
			do
				read -p "Please input decimal number: " DECIMAL
				if [[ "${DECIMAL}" =~ ^[0-9]+$ ]]
				then
					echo "Binary number: $(decimal_to_binary ${DECIMAL})"
					break
				else
					echo "Invalid input decimal number!" >&2
					continue
				fi
			done
			;;
		"Quit")
			echo "Quitting..."
			break
			;;
		*)
			echo "Invalid option" >&2
			;;
	esac
done

exit 0
