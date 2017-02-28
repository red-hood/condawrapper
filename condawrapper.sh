CONDA="$(which conda)"
CONDA_BIN="$(dirname "$(readlink -e "$CONDA")")"

cworkon() {
	source $CONDA_BIN/activate $1
	deactivate() {
		source deactivate
		unset -f deactivate
	}
}

_get_env_list() {
python3 <<SCRIPT
import json
import subprocess
import os

json_envs = subprocess.check_output(['conda', 'env', 'list', '--json'], universal_newlines=True)
envs_paths = json.loads(json_envs)['envs']
envs = set((os.path.basename(env_path) for env_path in envs_paths))
print(' '.join(envs))
SCRIPT
}

_cworkon_complete() {
    local cur envlist
    envlist="$(_get_env_list)"
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "${envlist}" -- ${cur}) )
}


#install register-python-argcomplete  in conda root environment
eval "$(register-python-argcomplete conda)"

complete -F _cworkon_complete cworkon
