
function die {
    msg=$@
    dt=`date +'%x %X'`
    echo "$0 error $dt: $msg" >&2
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
        echo "$0 info $dt: $msg"
    fi
}

function debug {
    if [[ ${DEBUG} > 0 ]]; then
        msg=$@
        dt=`date +'%x %X'`
        echo "$0 debug $dt: $msg"
    fi
}

function repeat() {
      eval "printf '${1}%.0s' {1..${2}}"
}

function ceiling() {
    local float_in=$1
    local ceil_val=${float_in/.*}
    if [ $float_in != $ceil_val ]; then 
        ceil_val=$((ceil_val+1))
    fi
    echo "$ceil_val"
}

function floor() {
    local float_in=$1
    local floor_val=${float_in/.*}
    if [ $float_in != $floor_val ]; then 
        floor_val=$((floor_val+1))
    fi
    echo "$floor_val"
}
