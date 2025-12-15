#!/bin/bash

OUTPUT_FOLDER="./release"
IMAGE_NAME="rfidtriggermanagerbuildrelease"

ensureOutputFolder(){
    echo "Creating empty release folder"
    if [ -d "$OUTPUT_FOLDER" ]; then
        rm -rf "$OUTPUT_FOLDER"/* 2>/dev/null
    fi

    mkdir -p "$OUTPUT_FOLDER"
}

buildReleaseImage() {
    echo "Building release image"
    docker build -f dockerfile-release -t $IMAGE_NAME .
}

getRelease() {
    ensureOutputFolder
    echo "Getting release files"
    docker run -v "$OUTPUT_FOLDER:/release" $IMAGE_NAME
}

dockerCleanup(){
    docker rm $(docker ps -a -q --filter ancestor=$IMAGE_NAME)
    docker rmi $IMAGE_NAME
}

initialise() {
    gotToProjectRoot
    buildReleaseImage
    getRelease
    dockerCleanup
}

gotToProjectRoot(){
    cd $PROJECT_ROOT_LOCATION
}

setWorkingDirToScriptLocation(){
    cd "$(dirname "$0")"
    PROJECT_ROOT_LOCATION=$(pwd)
}


## --- Startup ---
PROJECT_ROOT_LOCATION=""
setWorkingDirToScriptLocation

initialise
