unset __YADR_PREFERRED_SHELL
unset __YADR_INSTALL_ZSH

[[ -n "${__YADR_NO_PREFERRED_SHELL}" ]] && \
  [[ "${__YADR_NO_PREFERRED_SHELL}" == "false" ]] && \
    export __YADR_PREFERRED_SHELL=bash && \
    export __YADR_INSTALL_ZSH=n

