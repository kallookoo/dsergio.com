#!/usr/bin/env bash

function get_version() {
  local url="https://www.sublimetext.com/updates/3/${1}/appcast_osx.xml"
  local version="$(curl -v --silent ${url} --stderr - | grep 'sparkle:version' | grep -oE '[0-9]+' || echo '0000')"
  echo "${version}"
}

function get_subl_version() {
  local version="0000"
  local subl="/Applications/Sublime Text.app/Contents/SharedSupport/bin"
  local path_original="${PATH}"
  if [[ -d "${subl}" ]]; then
    version=`"${subl}/subl" --version | grep -oE '[0-9]+'`
  fi
  echo "${version}"
}

function main() {
  local notifier="/usr/local/bin/terminal-notifier"
  if [[ ! -f "${notifier}" ]]; then
    exit
  fi

  local stable_version="$(get_version stable)"
  local dev_version="$(get_version dev)"
  local current_version="$(get_subl_version)"
  local update_version="${dev_version}"

  if (( "${stable_version}" > "${dev_version}" )); then
    update_version="${stable_version}"
  fi

  if [[ "0000" = "${current_version}" ]]; then
    $notifier \
      -title "Sublime Text" \
      -subtitle "It seems that is not installed, you want to?" \
      -message "Click inside notification to download" \
      -sound "submarine" \
      -open "http://download.sublimetext.com/Sublime%20Text%20Build%20${update_version}.dmg"
  elif (( "${update_version}" > "${current_version}" )); then
    $notifier \
      -title "Sublime Text" \
      -subtitle "New version ${update_version} for the Sublime Text using" \
      -message "Click inside notification to download" \
      -sound "submarine" \
      -open "http://download.sublimetext.com/Sublime%20Text%20Build%20${update_version}.dmg" \
      -appIcon "" \
      -sender "com.sublimetext.3"
  fi
}

main
exit