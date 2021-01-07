#!/usr/bin/env bash
#
# Contains a wrapper for running C4F binaries, which allows for the use
# of 'dune exec'.


# If `DUNE_EXEC` is set to "true", calls to `act::exec` will run their program
# through `dune exec`.
declare DUNE_EXEC

# If set, overrides the choice of `act-c` executable.
declare C4F_C

# If set, overrides the choice of `act-fuzz` executable.
declare C4F_FUZZ


# Runs an OCaml C4F tool.
#
# If `DUNE_EXEC` is set to "true", the tool will be run indirectly through
# `dune exec`.
#
# Globals:
#   - DUNE_EXEC (read)
#
# Arguments:
#   1: the C4F program to execute.
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


# Runs the c4f 'c' tool.
#
# Globals:
#   - C4F_C (read)
#   - DUNE_EXEC (transitively read)
#
# Arguments:
#   *: the arguments to the program.
act::c() {
  act::exec "${C4F_C:-"c4f-c"}" "$@"
}


# Runs the c4f 'delitmus' sub-tool.
#
# Globals:
#   - C4F_C (read)
#   - DUNE_EXEC (transitively read)
#
# Arguments:
#   *: the arguments to the program.
act::delitmus() {
  # `delitmus` is currently `act-c delitmus`; this may change later.
  act::c delitmus "$@"
}


# Runs the c4f 'fuzz' tool.
#
# Globals:
#   - C4F_FUZZ (read)
#   - DUNE_EXEC (transitively read)
#
# Arguments:
#   *: the arguments to the program.
act::fuzz() {
  act::exec "${C4F_FUZZ:-"c4f"}" "$@"
}
