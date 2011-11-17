#!/bin/sh
readonly CLASSNAME="net.sourceforge.pmd.cpd.CPD"

usage() {
    echo "Usage:"
    echo "    $(basename $0) [-h]"
    echo ""
	echo "-h print this help"
}

is_cygwin() {
    case "$(uname)" in
        CYGWIN*)
            readonly cygwin=true
            ;;
    esac
    # OS specific support.  $var _must_ be set to either true or false.
    if [ -z ${cygwin} ] ; then
        readonly cygwin=false
    fi
}

cygwin_paths() {
    # For Cygwin, switch paths to Windows format before running java
    if ${cygwin} ; then
        JAVA_HOME=$(cygpath --windows "${JAVA_HOME}")
        classpath=$(cygpath --path --windows "${classpath}")
        DIRECTORY=$(cygpath --windows "${DIRECTORY}")
    fi
}

convert_cygwin_vars() {
    # If cygwin, convert to Unix form before manipulating
    if $cygwin ; then
        [ -n "${JAVA_HOME}" ] &&
            JAVA_HOME=$(cygpath --unix "${JAVA_HOME}")
        [ -n "${CLASSPATH}" ] &&
            CLASSPATH=$(cygpath --path --unix "${CLASSPATH}")
    fi
}

java_heapsize_settings() {
    local heapsize=${HEAPSIZE:-512m}
    case "${heapsize}" in
        [1-9]*[mgMG])
            readonly HEAPSIZE="-Xmx${heapsize}"
            ;;
        '')
            ;;
        *)
            echo "HEAPSIZE '${HEAPSIZE}' unknown (try: 512m)"
            exit 1
    esac
}

# move to java
#if [ -z "$3" ]; then
#    usage
#    exit 1
#fi

is_cygwin

readonly SCRIPT_DIR=$(dirname ${0})
CWD="${PWD}"

cd "${SCRIPT_DIR}/../lib"
readonly LIB_DIR=$(pwd -P)

convert_cygwin_vars

classpath="${CLASSPATH}"

cd "${CWD}"

for jarfile in ${LIB_DIR}/*.jar; do
    classpath=${classpath}:${jarfile}
done

cygwin_paths

java_heapsize_settings

java "${HEAPSIZE}" -cp "${classpath}" "${CLASSNAME}" ${@}
