#!/usr/bin/env bash

# Tries to compile the latest gcc, then updates a symlink to point to it.
# Expects GNU coreutils.

set -euo pipefail

readonly LFILE="${XDG_CONFIG_HOME:-"${HOME}/.config"}/act/scripts.local"
if ! [[ -e "${LFILE}" ]]; then
	echo "Need to create ${LFILE}" >&2
	exit 1
fi
source "${LFILE}"

COMPILERDIR=${COMPILERDIR:?"COMPILERDIR unset in ${LFILE}"}


# The directory into which we're putting GCC snapshots.
GCCDIR="${COMPILERDIR}/gcc-snapshots"
readonly GCCDIR
# The directory into which we're getting the source tree.
readonly GITDIR="${GCCDIR}/git"

do_git()
{
	if [[ -d "${GITDIR}" ]]; then
		pushd "${GITDIR}"
		git pull
		popd
	else
		git clone git://gcc.gnu.org/git/gcc.git "${GITDIR}"
	fi
}

# The prefix into which we're putting this GCC snapshot.
PREFIX="${GCCDIR}/$(date -I)"
readonly PREFIX
mkdir -p "${PREFIX}"

do_git

# per https://gcc.gnu.org/install/configure.html
rm -rf "${BUILDDIR}"
mkdir -p "${BUILDDIR}"
cd "${BUILDDIR}"

"${GITDIR}/configure" \
	--prefix="${PREFIX}"
make -j4
make install

ln -fsT "${FINALDIR}" "${GCCDIR}/latest"