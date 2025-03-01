#!/usr/bin/env bash

# Function to check return code
check_exit_status() {
        local EXIT_CODE="${?}"
        if [[ "${EXIT_CODE}" -ne 0 ]]
        then
                echo "Error: ${1} (exit code ${EXIT_CODE})" >&2
                exit 1
        fi
	return 0
}

# Function which download ubuntu server iso
download_ubuntu_server() {
        local SAVE_DIR="${1}"
	local FTP_SERVER="by.releases.ubuntu.com"
	local FTP_REMOTE_FILE_PATH="/releases/.pool/SHA256SUMS"
	local FTP_PATH="/releases/.pool"
	local REMOTE_FILE_SERVER="$(wget -q http://${FTP_SERVER}${FTP_REMOTE_FILE_PATH} -O - | awk '/24.04(\.[0-9])?-live-server-amd64.iso$/ {print $2}' | tr -d \*)"
	local CHECK_SHASUM_SERVER="$(wget -q http://${FTP_SERVER}${FTP_REMOTE_FILE_PATH} -O - | awk '/24.04(\.[0-9])?-live-server-amd64.iso$/ {print $1}')"

	# Check existing file and checksum
	if [[ -f "${SAVE_DIR}/${REMOTE_FILE_SERVER}" ]] && [[ "$(sha256sum ${SAVE_DIR}/${REMOTE_FILE_SERVER} | awk '{print $1}')" == "${CHECK_SHASUM_SERVER}" ]]
	then
		echo "${REMOTE_FILE_SERVER} was downloaded previously" >&2
		exit 1
	else
		rm "${SAVE_DIR}/${REMOTE_FILE_SERVER}" &> /dev/null
		# Cheching connection to the ftp server
		nc -zv -w1 "${FTP_SERVER}" 21 &>/dev/null
		check_exit_status "failed connection to the ${FTP_SERVER}"

		# Start FTP transfer
		ftp -n <<- _EOF_
		open "${FTP_SERVER}"
			user anonymous me@linuxbox
			binary
			cd "${FTP_PATH}"
			hash
			lcd "${SAVE_DIR}"
			mget "${REMOTE_FILE_SERVER}"
			bye
			_EOF_

		# Check if FTP command was successful
		check_exit_status "FTP download failed for ${REMOTE_FILE_SERVER}"

		echo "${REMOTE_FILE_SERVER} has alredy been downloaded"
		ls -l "${SAVE_DIR}/${REMOTE_FILE_SERVER}"
	fi
	return 0
}

# Function which download ubuntu desktop iso
download_ubuntu_desktop() {
        local SAVE_DIR="${1}"
	local FTP_SERVER="by.releases.ubuntu.com"
	local FTP_REMOTE_FILE_PATH="/releases/.pool/SHA256SUMS"
	local FTP_PATH="/releases/.pool"
	local REMOTE_FILE_DESKTOP="$(wget -q http://${FTP_SERVER}${FTP_REMOTE_FILE_PATH} -O - | awk '/24.04(\.[0-9])?-desktop-amd64.iso$/ {print $2}' | tr -d \*)"
	local CHECK_SHASUM_DESKTOP="$(wget -q http://${FTP_SERVER}${FTP_REMOTE_FILE_PATH} -O - | awk '/24.04(\.[0-9])?-desktop-amd64.iso$/ {print $1}')"

	# Check existing file and checksum
	if [[ -f "${SAVE_DIR}/${REMOTE_FILE_DESKTOP}" ]] && [[ "$(sha256sum ${SAVE_DIR}/${REMOTE_FILE_DESKTOP} | awk '{print $1}')" == "${CHECK_SHASUM_DESKTOP}" ]]
	then
		echo "${REMOTE_FILE_DESKTOP} was downloaded previously" >&2
		exit 1
	else
		rm "${SAVE_DIR}/${REMOTE_FILE_DESKTOP}" &> /dev/null
		# Cheching connection to the ftp server
		nc -zv -w1 "${FTP_SERVER}" 21 &>/dev/null
		check_exit_status "failed connection to the ${FTP_SERVER}"

		# Start FTP transfer
		ftp -n <<- _EOF_
		open "${FTP_SERVER}"
			user anonymous me@linuxbox
			binary
			cd "${FTP_PATH}"
			hash
			lcd "${SAVE_DIR}"
			mget "${REMOTE_FILE_DESKTOP}"
			bye
			_EOF_

		# Check if FTP command was successful
		check_exit_status "FTP download failed for ${REMOTE_FILE_DESKTOP}"

		echo "${REMOTE_FILE_DESKTOP} has alredy been downloaded"
		ls -l "${SAVE_DIR}/${REMOTE_FILE_DESKTOP}"
	fi
	return 0
}

# Function which download debian iso
download_debian() {
	local SAVE_DIR="${1}"
	local FTP_SERVER="ftp.by.debian.org"
	local FTP_REMOTE_FILE_PATH="/debian-cd/current/amd64/iso-dvd/SHA256SUMS"
	local FTP_PATH="/debian-cd/current/amd64/iso-dvd"
	local REMOTE_FILE_DEBIAN="$(wget -q http://${FTP_SERVER}${FTP_REMOTE_FILE_PATH} -O - | grep -vi 'update' | awk '/DVD-1.iso$/ {print $2}')"
	local CHECK_SHASUM_DEBIAN="$(wget -q http://${FTP_SERVER}${FTP_REMOTE_FILE_PATH} -O - | grep -vi 'update' | awk '/DVD-1.iso$/ {print $1}')"

	# Check existing file and checksum
	if [[ -f "${SAVE_DIR}/${REMOTE_FILE_DEBIAN}" ]] && [[ "$(sha256sum ${SAVE_DIR}/${REMOTE_FILE_DEBIAN} | awk '{print $1}')" == "${CHECK_SHASUM_DEBIAN}" ]]
	then
		echo "${REMOTE_FILE_DEBIAN} was downloaded previously" >&2
		exit 1
	else
		rm "${SAVE_DIR}/${REMOTE_FILE_DEBIAN}" &> /dev/null
		# Cheching connection to the ftp server
		nc -zv -w1 "${FTP_SERVER}" 21 &>/dev/null
		check_exit_status "failed connection to the ${FTP_SERVER}"

		# Start FTP transfer
		ftp -n <<- _EOF_
		open "${FTP_SERVER}"
			user anonymous me@linuxbox
			binary
			cd "${FTP_PATH}"
			hash
			lcd "${SAVE_DIR}"
			mget "${REMOTE_FILE_DEBIAN}"
			bye
			_EOF_

		# Check if FTP command was successful
		check_exit_status "FTP download failed for ${REMOTE_FILE_DEBIAN}"

		echo "${REMOTE_FILE_DEBIAN} has alredy been downloaded"
		ls -l "${SAVE_DIR}/${REMOTE_FILE_DEBIAN}"
	fi
	return 0
}

# Function which check downloading dir
check_downloading_dir() {
	local DIR USER USER_HOME FREE_SPACE ERRORS FUNCTION_NAME

	# Define empty ERRORS variable
	ERRORS=""

	# Get the name of the function being called
	FUNCTION_NAME="${1}"

	# Check passed function name
	if [[ -z "${FUNCTION_NAME}" ]]
	then
        	echo "Error: No function specified!" >&2
        	return 1
    	fi

	# Infinite loop for input path
	while [[ true ]]
	do
		# Request path from user inside function
		read -p "Input downloading directory: " DIR

		# Check for empty input
		if [[ -z "${DIR}" ]]
		then
			ERRORS+="Error: path cannot be empty!\n"
		fi

		# Check for root directory (before removing slashes)
        	if [[ "${DIR}" == "/" ]]
        	then
                	ERRORS+="Warning: You have specified the root directory (${DIR}). Be careful!\n"
			DIR="/"
        	fi

		# Handling ~ and ~user
		if [[ "${DIR}" =~ ^~([^/]*) ]]
		then
        		USER="${BASH_REMATCH[1]}"

        		if [[ -z "${USER}" ]]
			then
            			DIR="$HOME${DIR:1}"
        		else
            			USER_HOME="$(getent passwd ${USER} | cut -d ':' -f 6)"
            			if [[ -n "${USER_HOME}" ]]
				then
                			DIR="$USER_HOME${DIR#~$USER}"
            			fi
        		fi
    		fi

		# Handling ., .., ../.. etc
                DIR="$(realpath ${DIR})"

		# Remove extra slashes, but not for the root
		if [[ "$DIR" != "/" ]]
		then
			DIR="$(echo ${DIR} | sed 's:/*$::')"
		fi

		# **EARLY EXIT** if the directory is not a directory
		if [[ ! -d "${DIR}" ]]
		then
        		ERRORS+="Error: ${DIR} does not exist or is not a directory!\n"
		fi

		# Check for read, write, and execute permissions only if the directory exists
    		if [[ -d "${DIR}" ]]
		then
			if [[ ! -r "${DIR}" ]]
			then
        			ERRORS+="Error: You do not have permission to read ${DIR}!\n"
			fi

    			if [[ ! -w "${DIR}" ]]
			then
        			ERRORS+="Error: You do not have write permissions to ${DIR}!\n"
			fi

    			if [[ ! -x "${DIR}" ]]
			then
        			ERRORS+="Error: You do not have execute permissions in ${DIR}!\n"
			fi
		fi

		# Check if it is a symbolic link
    		if [[ -d "${DIR}" ]] && [[ -L "${DIR}" ]]
		then
        		ERRORS+="Note: ${DIR} is a symbolic link!\n"
		fi

		# Check if directory exists and is a directory before checking free space
		if [[ -d "${DIR}" ]]
		then
			# Check free disk space
			FREE_SPACE="$(df ${DIR} | awk 'NR==2 {print $4}')"

			# Check if there is enough free space (eg 1000 1K blocks)
			if [[ "${FREE_SPACE}" -lt 1000 ]]
			then
        			ERRORS+="Error: Not enough free disk space to operate in $DIR!\n"
    			fi
		fi

		# If there are errors, we output them and continue the loop
		if [[ -n "${ERRORS}" ]]
		then
            		echo -e "${ERRORS}" >&2
            		ERRORS=""
            		continue
        	else
			# If all checks are successful, we pass DIR to other functions
			"${FUNCTION_NAME}" "${DIR}"
			break
		fi
	done
	return 0
}

# Main menu
ubuntu_menu() {
	local PS3="Please choose your linux distribution: "
	local UBUNTU_OPTIONS=("Ubuntu Server" "Ubuntu Desktop" "Debian" "Quit")
	select UBUNTU_OPT in "${UBUNTU_OPTIONS[@]}"
	do
		case "${UBUNTU_OPT}" in
    			"Ubuntu Server")
     				check_downloading_dir download_ubuntu_server
      				;;
    			"Ubuntu Desktop")
    				check_downloading_dir download_ubuntu_desktop
      				;;
			"Debian")
				check_downloading_dir download_debian
				;;
    			"Quit")
     				echo "Bye!"
      				break
      				;;
    			*)
      				echo "Incorrect option ${REPLY}" >&2
				;;
  		esac
  		REPLY=
	done
}
ubuntu_menu

exit 0
