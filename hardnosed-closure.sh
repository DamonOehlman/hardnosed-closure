#!/usr/bin/env bash

# strict mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -uo pipefail
shopt -s nullglob
IFS=$'\n\t'

CLOSURE_RELEASE="20160208"

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
	for flag in ${JSCOMP_ERRORS[@]}; do
		ARGS+=(--jscomp_error $flag)
	done

	for flag in ${JSCOMP_WARNINGS[@]}; do
		ARGS+=(--jscomp_warning $flag)
	done

	ARGS+=(--language_in ECMASCRIPT5)
	ARGS+=(--charset UTF-8)
	ARGS+=(--warning_level VERBOSE)
	ARGS+=(--summary_detail_level 3)
	ARGS+=(--compilation_level ADVANCED_OPTIMIZATIONS)

	echo "${ARGS[*]}"
}

checkJava() {
  hash "java" || (echo "you need java installed to run closure compiler, sorry :("; exit 1;)
}

installCompiler() {
  if [ ! -f ./compiler.jar ]; then
    echo "downloading the ${CLOSURE_RELEASE} version of closure compiler"
    curl "http://dl.google.com/closure-compiler/compiler-${CLOSURE_RELEASE}.tar.gz" | tar -xz --include="compiler.jar"
  fi
}

main() {
  checkJava && installCompiler
  java -jar compiler.jar $(genClosureArgs) $@
}

main "$@"