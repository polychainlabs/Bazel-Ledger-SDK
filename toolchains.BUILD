load(":cc_toolchain_config.bzl", "cc_toolchain_config")

package(default_visibility = ["//visibility:public"])

filegroup(name = "empty")

filegroup(
    name = "gcc-toolchain-archive",
    srcs = glob(["gcc-toolchain-archive/**"]),
)

filegroup(
    name = "llvm-toolchain-archive",
    srcs = glob(["llvm-toolchain-archive/**"]),
)

filegroup(
    name = "files",
    srcs = [
        "bin/ar",
        "bin/clang",
        "bin/clang++",
        "bin/gcc",
        "bin/ld",
        "bin/nm",
        "bin/objcopy",
        "bin/objdump",
        "bin/strip",
        ":gcc-toolchain-archive",
        ":llvm-toolchain-archive",
    ],
)

cc_toolchain_config(name = "cc_toolchain_config")

cc_toolchain(
    name = "ledger_toolchain",
    all_files = ":files",
    ar_files = ":files",
    compiler_files = ":files",
    dwp_files = ":empty",
    linker_files = ":files",
    objcopy_files = ":files",
    strip_files = ":files",
    supports_param_files = False,
    toolchain_config = ":cc_toolchain_config",
    toolchain_identifier = "ledger-toolchain",
)

toolchain(
    name = "cc-toolchain-ledger-osx",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:osx",
    ],
    target_compatible_with = [
        "@platforms//cpu:arm",
        "@platforms//os:linux",
        "//platforms:nanos-device",
    ],
    toolchain = ":ledger_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

toolchain(
    name = "cc-toolchain-ledger-linux",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:arm",
        "@platforms//os:linux",
        "//platforms:nanos-device",
    ],
    toolchain = ":ledger_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
