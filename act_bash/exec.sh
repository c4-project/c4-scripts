#!/usr/bin/env bash
#
# Contains a wrapper for running ACT binaries, which allows for the use
# of 'dune exec'.


# If `DUNE_EXEC` is set to "true", calls to `act::exec` will run their program
# through `dune exec`.
declare DUNE_EXEC

# If set, overrides the choice of `act-c` executable.
declare ACT_C

# If set, overrides the choice of `act-fuzz` executable.
declare ACT_FUZZ


# Runs an OCaml ACT tool.
#
# If `DUNE_EXEC` is set to "true", the tool will be run indirectly through
# `dune exec`.
#
# Globals:
#   - DUNE_EXEC (read)
#
# Arguments:
#   1: the ACT program to execute.
#   *: the arguments to the program.
act::exec() {
  local prog=$1

  # This convoluted mush is supposed to insert -v if VERBOSE is set, but
  # only _after_ the subcommand name, if it is present.
  local vflag=""
  if [[ ${VERBOSE} = "true" ]]; then
    vflag="-v"
  fi
  local subcom="$2"

  if [[ ${DUNE_EXEC} = "true" ]]; then
    # We can't build here because some of the act scripts fork off multiple
    # act tool executions, and building on each would cause race conditions.
    dune exec --no-build --display=quiet "${prog}" -- ${subcom:+"$subcom"} ${vflag:+"$vflag"} "${@:3}"
  else
    "${prog}" ${subcom:+"$subcom"} ${vflag:+"$vflag"} "${@:3}"
  fi
}


# Runs the ACT 'c' tool.
#
# Globals:
#   - ACT_C (read)
#   - DUNE_EXEC (transitively read)
#
# Arguments:
#   *: the arguments to the program.
act::c() {
  act::exec "${ACT_C:-"act-c"}" "$@"
}


# Runs the ACT 'delitmus' sub-tool.
#
# Globals:
#   - ACT_C (read)
#   - DUNE_EXEC (transitively read)
#
# Arguments:
#   *: the arguments to the program.
act::delitmus() {
  # `delitmus` is currently `act-c delitmus`; this may change later.
  act::c delitmus "$@"
}


# Runs the ACT 'fuzz' tool.
#
# Globals:
#   - ACT_FUZZ (read)
#   - DUNE_EXEC (transitively read)
#
# Arguments:
#   *: the arguments to the program.
act::fuzz() {
  act::exec "${ACT_FUZZ:-"act-fuzz"}" "$@"
}
