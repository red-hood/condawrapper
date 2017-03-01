_get_conda_root() {
	local conda conda_bin
	conda="$(which conda)"
	if [ -z "$conda" ]; then
		return 1
	fi
	conda_bin="$(dirname "$(readlink -e "$conda")")"
	echo "$(dirname "$conda_bin")"
}
CONDA_ROOT_PREFIX="$(_get_conda_root)"
unset -f _get_conda_root

if [ -z "${CONDA_ROOT_PREFIX}" ]; then
	unset CONDA_ROOT_PREFIX
	>&2 echo "condawrapper: Could not find conda root environment"
	return 1
fi

cworkon() {
	source $CONDA_ROOT_PREFIX/bin/activate $1
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


#install register-python-argcomplete in conda root environment
eval "$("${CONDA_ROOT_PREFIX}/bin/register-python-argcomplete" conda)"

complete -F _cworkon_complete cworkon
