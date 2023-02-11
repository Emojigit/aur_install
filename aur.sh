#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root."
  exit
fi

mkdir -p /var/aur
chown aur:aur /var/aur

get_dir() {
    echo "/var/aur/$1"
}

fetch() {
    echo "Running fetch $1"
    REPO_DIR="$(get_dir $1)"
    if [ -d "$REPO_DIR" ]; then
        cd "$REPO_DIR"
        git pull
    else
        git clone "https://aur.archlinux.org/$1.git" "$REPO_DIR" --depth 1
    fi
    exit $([ -d "$REPO_DIR" ])
}

make() {
    echo "Running make $1"
    REPO_DIR="$(get_dir $1)"
    cd "$REPO_DIR"
    git clean -dfX
    makepkg -cf
    exit $?
}

install() {
    echo "Running install $1"
    REPO_DIR="$(get_dir $1)"
    cd "$REPO_DIR"
    pacman -U *.pkg.tar.zst --needed
}

export -f get_dir
export -f fetch
export -f make

runuser aur -s /bin/bash -c "fetch $1; exit \$?" && runuser aur -s /bin/bash -c "make $1; exit \$?" && install $1
