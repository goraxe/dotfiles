#!/bin/bash

# bring in user config for overrides
if [[ -e ${HOME}/.dotfiles ]]; then
	source ${HOME}/.dotfiles
fi


#################################################################################
#
#								GLOBALS
#
#################################################################################



if [[ -z ${VSC_LOCATION} ]]; then
	# default scripts location
	VSC_LOCATION="svn://svn/home/trunk"
fi

if [[ -z ${VSC_LOCATION_USER} ]]; then
	VSC_LOCATION_USER="${VSC_LOCATION}/${USER}"
fi

if [[ -z ${VSC_LOCATION_BIN} ]]; then
	VSC_LOCATION_BIN="${VSC_LOCATION}/bin"
fi

if [[ -z ${CHECKOUT_HOME} ]]; then
	CHECKOUT_HOME="${HOME}/.${USER}_home_svn"
fi

if [[ -z ${BIN_CHECKOUT} ]]; then
	CHECKOUT_BIN="${CHECKOUT_HOME}/bin.yellow"
fi

if [[ -z ${VCS_UPDATE_CMD} ]]; then
	VCS_UPDATE_CMD="svn up"
fi

if [[ -z ${VCS_CREATE_CMD} ]]; then
	VCS_CREATE_CMD="svn co"
fi

if [[ -z ${VCS_LOCATION_CMD} ]]; then
	VCS_LOCATION_CMD='svn info | grep "Repository Root:" | cut -d" " -f3'
fi

#################################################################################
#
#								FUNCTIONS
#
#################################################################################

# keep here rather than attempting to source functions.sh as this script is used for bootstraping

function die {
	msg=$1
	echo ${msg}
	exit -1
}

function is_vcs {
	dir=$1
	echo "is_vcs called with ${dir}"
	return [[ -e "${dir}/.svn" ]] || [[ -e "{$dir}/.git" ]]
}

function dir_update {
	dir=$1
	vcs_location=$2
	# is it the same location
	if [[ -d ${dir} ]]; then
		is_vcs "${dir}"
		IS_VCS=$?
		is_vcs_location ${dir} ${vcs_location}
		IS_VCS_LOCATION=$?
		if [[ ${IS_VCS} &&  ${IS_VCS_LOCATION} ]]; then
			${VCS_UPDATE_CMD} ${dir}
			return
		else 
			echo "existing ${dir} being backed up to ${dir}.bck" 
			mv ${dir} ${dir}.bck
		fi
	fi
	vcs_create ${dir} ${vcs_location}
}

function vcs_create {
	dir=$1
	vcs_location=$2
	${VCS_CREATE_CMD} ${vcs_location} ${dir}  || die "could not checkout ${vcs_location} to ${dir}"
}

function is_vcs_location {
	dir=$1
	vcs_location=$2
	push ${dir}
	repo=`$VCS_LOCATION_CMD`
	popd
#	repo=`svn info $dir | grep "Repository Root:" | cut -d" " -f 3`
	[[ ${vcs_location} == ${repo} ]]
	return 
}

#################################################################################
#
#								MAIN
#
#################################################################################



# do checkouts

for repo in ${VCS_DIRS}; do
	LOC=$(eval "echo \$$(echo VCS_LOCATION_${repo})")
	DIR=$(eval "echo \$$(echo CHECKOUT_${repo})")

	echo "syncing repository ${repo} from ${LOC}  to ${DIR}"
	dir_update ${DIR} ${LOC}

	shopt -s dotglob


	for files in ${DIR}/* 
	do
		
	#	echo "file >> ${files}"
		bname=`basename ${files}`
		if [[ ${bname} == ".svn" ]]; then
			continue
		fi
		echo "file >> ${files} bname >> ${bname}"
		dest="${HOME}/${bname}"

		# if we have dry run dont copy 
		if [[ ! -z ${DRY_RUN} ]]; then
			continue
		fi

		# its a link allready make sure it points where we want
		if [[ -L ${dest} ]]; then
			rm ${dest} || die "could not remove link ${dest}"
		elif [[ -e ${dest} ]]; then # dest exists move it to bck
			mv ${dest} ${dest}.bck
		fi
		ln -s ${files} ${dest}
	done 
done
