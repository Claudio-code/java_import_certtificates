#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

println () {
    local message="$1"
    echo -e "${GREEN}[INFO]${NC} - ${message}"
}

transform_crt_to_der () {
    local fileName=$(basename -- "$1")
    local fileNameWithoutExtension="${fileName%.*}"
    println "Converter $fileName to .der extensions."
    
    openssl x509 -in "$fileName" -outform der -out "$fileNameWithoutExtension.der"
}

import_keys_to_java_cacerts () {
    local fileName=$(basename -- "$1")
    local fileNameWithoutExtension="${fileName%.*}"
    println "Import it key $fileName to java path: $javaPath ."
    
    keytool -importcert -trustcacerts -alias "$fileNameWithoutExtension" -keystore "$javaPath" -storepass changeit -file "./$fileName"
}

load_der_files () {
    for file in ./*.der; do
        import_keys_to_java_cacerts "$file"
    done    
}

load_crt_files () {
    for file in ./*.crt; do
        transform_crt_to_der "$file"
    done
}

while getopts j:k: flag
do
    case "${flag}" in
        j) javaPath=${OPTARG};;
        k) keyPath=${OPTARG};;
    esac
done


println "Import all keys to java path."
cd $keyPath
load_crt_files
load_der_files
