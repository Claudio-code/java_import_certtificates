#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

JAVA_VENDOR=$(java -version 2>&1 | head -n 3 | awk -F 'Runtime' '{print $2}' | tr '\n' ' ')
JAVA_VENDOR_OUT=($JAVA_VENDOR)
JAVA_ONLY_VERSION=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
JAVA_ONLY_VERSION_OUT=($JAVA_ONLY_VERSION)

println() {
	local message="$1"
	echo -e "${GREEN}[INFO]${NC} - ${message}"
}

transform_crt_to_der() {
	local fileName=$(basename -- "$1")
	local fileNameWithoutExtension="${fileName%.*}"
	println "Converter $fileName to .der extensions."

	openssl x509 -in "$fileName" -outform der -out "$fileNameWithoutExtension.der"
}

import_keys_to_java_cacerts() {
	local fileName=$(basename -- "$1")
	local fileNameWithoutExtension="${fileName%.*}"
	println "Import it key $fileName to java path: $JAVA_HOME ."

	if [[ "${JAVA_ONLY_VERSION_OUT[*]}" =~ '1.8.' ]]; then
		if [[ "${JAVA_VENDOR_OUT[*]}" =~ 'LTS' || "${JAVA_VENDOR_OUT[*]}" =~ 'Correto' || "${JAVA_VENDOR_OUT[*]}" =~ 'Termurin' ]]; then
			sudo $JAVA_HOME/bin/keytool -importcert -file "./$fileName" -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit -alias "$fileNameWithoutExtension" -noprompt
		else
			sudo $JAVA_HOME/bin/keytool -importcert -file "./$fileName" -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit -alias "$fileNameWithoutExtension" -noprompt
		fi
	else
		sudo $JAVA_HOME/bin/keytool -importcert -file "./$fileName" -cacerts -storepass changeit -alias "$fileNameWithoutExtension" -noprompt
	fi
}

load_der_files() {
	for file in ./*.der; do
		if [ -d "$file" ]; then
			for dir in "$file/*"; do
				for fileSubDir in "$dir"; do
					import_keys_to_java_cacerts "$fileSubDir"
				done
			done
		else
			import_keys_to_java_cacerts "$file"
		fi
	done
}

load_crt_files() {
	for file in ./*.crt; do
		transform_crt_to_der "$file"
	done
}

while getopts j:k: flag; do
	case "${flag}" in
	k) keyPath=${OPTARG} ;;
	esac
done

println "Import all keys to java path."
cd $keyPath
load_crt_files
load_der_files
