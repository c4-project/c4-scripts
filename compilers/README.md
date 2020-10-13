# Compiler provisioning scripts

These scripts are quick-and-dirty wrappers over the Clang and GCC build
processes, intended for semi-automatically compiling nightlies of those
compilers in the absence of more sophisticated `act-tester` support.

They expect a script to be installed in `act/scripts.local` with the following
variables:

- `COMPILERDIR`: where you want the compilers installed;
- `CLANG_TARGETS`: passed directly into `LLVM_TARGETS_TO_BUILD`.
