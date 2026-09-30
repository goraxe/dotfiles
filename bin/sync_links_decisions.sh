#!/bin/bash
set -eu

BINDIR=$(dirname "$0")

# bring in user config for overrides
if [[ -e ${HOME}/.dotfiles ]]; then
	source "${HOME}/.dotfiles"
elif [[ -e ${HOME}/etc/shell-conf ]]; then
	source "${HOME}/etc/shell-conf"
elif [[ -e ${BINDIR}/../etc/shell-conf ]]; then
	source "${BINDIR}/../etc/shell-conf"
else
	echo "do not know what to sync please setup a .dotfiles rc file"
	exit 1
fi

normalize_vcs_location() {
	location=$1

	case "${location}" in
		git@github.com:*)
			location="https://github.com/${location#git@github.com:}"
			;;
		https://github.com:*)
			location="https://github.com/${location#https://github.com:}"
			;;
	esac

	location=${location%.git}
	location=${location%/}
	printf '%s\n' "${location}"
}

repo_cmd_for_dir() {
	if [[ ${VCS_UPDATE_CMD:-} == git* ]]; then
		printf '%s\n' 'git remote get-url origin'
		return
	fi

	repo_cmd="${VCS_LOCATION_CMD}"
	if [[ -n ${VCS_LOCATION_CMD_GREP:-} ]]; then
		repo_cmd="${repo_cmd} | ${VCS_LOCATION_CMD_GREP}"
	fi
	if [[ -n ${VCS_LOCATION_CMD_CUT:-} ]]; then
		repo_cmd="${repo_cmd} | ${VCS_LOCATION_CMD_CUT}"
	fi
	printf '%s\n' "${repo_cmd}"
}

is_vcs() {
	dir=$1
	[[ -e "${dir}/.svn" || -e "${dir}/.git" ]]
}

repo_location_for_dir() {
	dir=$1
	pushd "${dir}" >/dev/null
	repo_cmd=$(repo_cmd_for_dir)
	repo=$(eval "${repo_cmd}" 2>/dev/null || true)
	popd >/dev/null
	printf '%s\n' "${repo}"
}

for repo in ${VCS_DIRS}; do
	LOC=$(eval "echo \$$(echo VCS_LOCATION_${repo})")
	DIR=$(eval "echo \$$(echo CHECKOUT_${repo})")
	DEST_VAR="DEST_${repo}"
	DEST="${!DEST_VAR-}"

	echo "===== ${repo} ====="
	echo "configured location: ${LOC}"
	echo "checkout dir: ${DIR}"
	echo "dest dir: ${DEST:-<none>}"
	if [[ -d ${DIR} ]]; then
		echo "dir exists: yes"
		if is_vcs "${DIR}"; then
			is_vcs_result=yes
		else
			is_vcs_result=no
		fi
		echo "is vcs dir: ${is_vcs_result}"
		repo_cmd=$(repo_cmd_for_dir)
		echo "repo detect cmd: ${repo_cmd}"
		raw_repo=$(repo_location_for_dir "${DIR}")
		echo "raw repo detect result: ${raw_repo:-<empty>}"
		normalized_actual=$(normalize_vcs_location "${raw_repo}")
		normalized_expected=$(normalize_vcs_location "${LOC}")
		echo "normalized actual: ${normalized_actual:-<empty>}"
		echo "normalized expected: ${normalized_expected}"
		if [[ ${normalized_actual} == ${normalized_expected} && ${is_vcs_result} == yes ]]; then
			echo "decision: UPDATE existing checkout"
			echo "would run: (cd \"${DIR}\" && ${VCS_UPDATE_CMD})"
		else
			echo "decision: BACKUP + CREATE fresh checkout"
			echo "would backup: ${DIR} -> ${DIR}.bck"
			echo "would run: ${VCS_CREATE_CMD} ${LOC} \"${DIR}\""
		fi
	else
		echo "dir exists: no"
		echo "decision: CREATE fresh checkout"
		echo "would run: ${VCS_CREATE_CMD} ${LOC} \"${DIR}\""
	fi
	echo
 done
