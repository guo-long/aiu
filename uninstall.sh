#!/bin/bash

# gnome-orca: screen reader
apt-get -y purge gnome-mahjongg gnome-mines gnome-orca gnome-sudoku
apt-get -y purge libreoffice-*
# remove amazon link
#apt-get -y purge unity-webapps-common
# [deja-dup: backup] [onboard: keyboard on screen] [totem: video player] [zeitgeist: activity log utility]
apt-get -y purge aisleriot cheese deja-dup imagemagick* onboard rhythmbox shotwell* simple-scan webbrowser-app
