#!/usr/bin/env bash

# strict mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -uo pipefail
shopt -s nullglob
IFS=$'\n\t'

CLOSURE_RELEASE="20160208"
DIR=$(dirname "$0")
CC_RELEASES_DIR="${DIR}"/cc-releases
INSTALL_ONLY=0

# define the --jscomp_error flags we want to use
JSCOMP_ERRORS=(
	accessControls
	checkRegExp
	checkTypes
	uselessCode
	checkVars
	const
	globalThis
	nonStandardJsDocs
	missingProperties
	strictModuleDepCheck
	suspiciousCode
	undefinedNames
	visibility
)

# define the --jscomp_warning flags
JSCOMP_WARNINGS=(
	deprecated
)

function genClosureArgs() {
	ARGS=()
	for flag in "${JSCOMP_ERRORS[@]}"; do
		ARGS+=(--jscomp_error $flag)
	done

	for flag in "${JSCOMP_WARNINGS[@]}"; do
		ARGS+=(--jscomp_warning $flag)
	done

	ARGS+=(--language_in ECMASCRIPT6)
	ARGS+=(--charset UTF-8)
	ARGS+=(--warning_level VERBOSE)
	ARGS+=(--new_type_inf)
	ARGS+=(--summary_detail_level 3)
	ARGS+=(--compilation_level ADVANCED_OPTIMIZATIONS)

	echo "${ARGS[*]}"
}

checkJava() {
  hash "java" || (echo "you need java installed to run closure compiler, sorry :("; exit 1;)
}

maybeDownloadCompiler() {
	mkdir -p "${CC_RELEASES_DIR}"
	if [ ! -f "${CC_RELEASES_DIR}/compiler-${CLOSURE_RELEASE}.tar.gz" ]; then
		echo "downloading closure release ${CLOSURE_RELEASE}"
		wget --quiet --directory-prefix="${CC_RELEASES_DIR}" "http://dl.google.com/closure-compiler/compiler-${CLOSURE_RELEASE}.tar.gz";
		extractCompiler
	fi

	if [ ! -f "${CC_RELEASES_DIR}/compiler.jar" ]; then
		extractCompiler
	fi
}

extractCompiler() {
	echo "extracting compiler"
	tar xzf "${CC_RELEASES_DIR}/compiler-${CLOSURE_RELEASE}.tar.gz" -C "${CC_RELEASES_DIR}"
}

main() {
  checkJava && maybeDownloadCompiler

	if [ "${INSTALL_ONLY}" != 1 ]; then
		java -jar "${CC_RELEASES_DIR}/compiler.jar" $(genClosureArgs) $@
	fi
}

while getopts ":install:" opt; do
	case $opt in
		i|install)
			INSTALL_ONLY=1
			;;
	esac
done

main "$@"
