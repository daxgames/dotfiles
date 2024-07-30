if [[ $(uname) == Linux ]]; then
    function unlock-keyring () {
        stty -echo
        printf "Linux Keyring Password: "
        read pass
        stty echo
        printf "\n"
        export $(echo -n "$pass" | gnome-keyring-daemon --unlock --replace --components=pkcs11,secrets,ssh)
        unset pass
    }
fi

if [ -e ~/.secrets ]; then
  source ~/.secrets
fi
