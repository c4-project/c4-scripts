#!/usr/bin/env bash

# Tries to compile the latest clang, then updates a symlink to point to it.
# Expects GNU coreutils.

set -euo pipefail

readonly LFILE="${XDG_CONFIG_HOME:-"${HOME}/.config"}/c4t/scripts.local"
if ! [[ -e "${LFILE}" ]]; then
	echo "Need to create ${LFILE}" >&2
	exit 1
fi
source "${LFILE}"

COMPILERDIR=${COMPILERDIR:?"COMPILERDIR unset in ${LFILE}"}
CLANG_TARGETS=${CLANG_TARGETS:?"CLANG_TARGETS unset in ${LFILE}"}


# The directory into which we're putting Clang snapshots.
CLANGDIR="${COMPILERDIR}/clang-snapshots"
readonly CLANGDIR
# The directory into which we're getting the source tree.
readonly GITDIR="${CLANGDIR}/git"	
# The directory into which we're building.
readonly BUILDDIR="${CLANGDIR}/build"	

do_git()
{
	if [[ -d "${GITDIR}" ]]; then
		pushd "${GITDIR}"
		git pull
		popd
	else
		git clone https://github.com/llvm/llvm-project.git "${GITDIR}"
	fi
}

# The directory into which we're putting this Clang snapshot.
PREFIX="${CLANGDIR}/$(date -I)"
readonly PREFIX
mkdir -p "${PREFIX}"

do_git

# per https://clang.llvm.org/get_started.html
rm -rf "${BUILDDIR}"
mkdir -p "${BUILDDIR}"
cd "${BUILDDIR}"

# Release because non-Release configurations nom a lot of HDD space
cmake \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DLLVM_ENABLE_PROJECTS=clang \
	-DLLVM_TARGETS_TO_BUILD="${CLANG_TARGETS}" \
	-G "Ninja" "${GITDIR}/llvm"
cmake --build .
cmake --build . --target install

ln -fsT "${PREFIX}" "${CLANGDIR}/latest"
