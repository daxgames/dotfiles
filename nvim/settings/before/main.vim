" This is where you can configure anything that needs to be loaded or
" configured before the rest of the configuration and/or before some plugin
" get loaded. For example, changing the leader key to your desire.

" Just put a new .vim file in this folder and it will get sourced here. Those
" files will be ignored by git so you don't need to fork the repo just for
" these kind of customizations.

let customSettingsPath = '~/.config/nvim/settings/before'

for fpath in split(globpath(customSettingsPath, '*.vim'), '\n')
  if (substitute(fpath, '/', '\', '') != expand(customSettingsPath . "/main.vim")) " skip main.vim (this file)
    exe 'source' fpath
  endif
endfor
