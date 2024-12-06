# Define zim location
(( ! ${+ZIM_HOME} )) && export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Source user configuration
[[ -s ${ZDOTDIR:-${HOME}}/.zimrc ]] && source ${ZDOTDIR:-${HOME}}/.zimrc

# Set input mode before loading modules
if [[ ${zinput_mode} == 'vi' ]]; then
  bindkey -v
else
  bindkey -e
fi

# Autoload module functions
() {
  local mod_function
  setopt LOCAL_OPTIONS EXTENDED_GLOB

  # autoload searches fpath for function locations; add enabled module function paths
  fpath=(${ZIM_HOME}/modules/${^zmodules}/functions(/FN) ${fpath})

  for mod_function in ${ZIM_HOME}/modules/${^zmodules}/functions/^(_*|prompt_*_setup|*.*)(-.N:t); do
    autoload -Uz ${mod_function}
  done
}

# Initialize modules
() {
  local zmodule zmodule_dir zmodule_file

  for zmodule in ${zmodules}; do
    zmodule_dir=${ZIM_HOME}/modules/${zmodule}
    if [[ ! -d ${zmodule_dir} ]]; then
      print "No such module \"${zmodule}\"." >&2
    else
      for zmodule_file in ${zmodule_dir}/init.zsh \
          ${zmodule_dir}/{,zsh-}${zmodule}.{zsh,plugin.zsh,zsh-theme,sh}; do
        if [[ -f ${zmodule_file} ]]; then
          source ${zmodule_file}
          break
        fi
      done
    fi
  done
}
