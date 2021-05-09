#!/bin/bash

BINDIR=$(dirname $0)


# bring in user config for overrides
if [[ -e ${HOME}/.dotfiles ]]; then
	source ${HOME}/.dotfiles
elif [[ -e ${HOME}/etc/shell-conf ]]; then
	source ${HOME}/etc/shell-conf
elif [[ -e ${BINDIR}/../etc/shell-conf ]]; then
	source ${BINDIR}/../etc/shell-conf
else 
	echo "do not know what to sync please setup a .dotfiles rc file"
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
    [[ -e "${dir}/.svn" || -e "{$dir}/.git" ]]
	return $?
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
            echo "going to run update_cmd: ${VCS_UPDATE_CMD} ${dir}"
            pushd ${dir}
			${VCS_UPDATE_CMD} 
            #${dir}
            popd
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
    echo "going to run create_cmd: ${VCS_CREATE_CMD} {$vcs_location} ${dir}"
	${VCS_CREATE_CMD} ${vcs_location} ${dir}  || die "could not checkout ${vcs_location} to ${dir}"
}

function is_vcs_location {
	dir=$1
	vcs_location=$2
	pushd ${dir}
    echo "vcs_location_cmd: $VCS_LOCATION_CMD"
	repo=$($VCS_LOCATION_CMD)
	popd
	# echo "REPO = ${repo} vcs_location = ${vcs_location}"
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
    DEST=$(eval "echo \$$(echo DEST_${repo})")

	echo "syncing repository ${repo} from ${LOC}  to ${DIR}"
	dir_update ${DIR} ${LOC}

	shopt -s dotglob

	if [[ -z $DEST ]]; then
		continue
	fi

    if [[ ! -d $DEST ]]; then 
        mkdir $DEST
    fi
	for files in ${DIR}/* 
	do
		
	#	echo "file >> ${files}"
		bname=`basename ${files}`
		if [[ ${bname} == ".svn" ]]; then
			continue
		fi
		if [[ ${bname} == ".git" ]]; then
			continue
		fi
		echo "file >> ${files} bname >> ${bname}"
		bdest="${DEST}/${bname}"

		# if we have dry run dont copy 
		if [[ ! -z ${DRY_RUN} ]]; then
			continue
		fi

		# its a link allready make sure it points where we want
		if [[ -L ${bdest} ]]; then
			rm ${bdest} || die "could not remove link ${bdest}"
		elif [[ -e ${bdest} ]]; then # dest exists move it to bck
			mv ${bdest} ${bdest}.bck
		fi
		ln -s ${files} ${bdest}
	done 
done
