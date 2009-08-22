
function die {
	msg=$@
	dt=`date +'%x %X'`
	echo "$0 $dt: $msg" >&2
	exit -1
}

function safe_mkdir {
	DIR=$@

	if [[ -e ${DIR} ]]; then
		if [[ ! -d ${DIR} ]]; then
			die "${DIR} is not a directory"
		fi
	else
		say "creating ${DIR}"
		if [[ $DRY_RUN > 0 ]]; then
			return;
		fi
		mkdir ${DIR} || die "could not mkdir ${DIR}"
	fi
}

function say {
	if [[ ${VERBOSE} > 0 ]]; then
		msg=$@
		dt=`date +'%x %X'`
		echo "$0 $dt: $msg"
	fi
}

