if [[ $(uname) == Linux ]] && [[ -n "$(command -v gnome-keyring-daemon)" ]]; then
    function unlock-keyring () {
        printf "Linux Keyring Password: "
        stty -echo
        read pass
        stty echo
        printf "\n"
        export $(echo -n "$pass" | gnome-keyring-daemon --unlock --replace --components=pkcs11,secrets,ssh)
        unset pass
    }

    if [[ $- == *i* ]]; then  # Only run in interactive mode
      if [[ -z "${XDG_CURRENT_DESKTOP}" ]] && [[ -n "$(command -v dbus-run-session)" ]]; then
        if test -z "$DBUS_SESSION_BUS_ADDRESS" ; then
          exec dbus-run-session -- $SHELL
        fi

        gnome-keyring-daemon --start --components=pkcs11,secrets,ssh 2>/dev/null >/dev/null
      fi
    fi
fi

if [ -e ~/.secrets ]; then
  source ~/.secrets
fi
