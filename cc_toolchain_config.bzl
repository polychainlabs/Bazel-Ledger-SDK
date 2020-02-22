load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "feature",
    "flag_group",
    "flag_set",
    "tool",
    "tool_path",
)
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

all_compile_actions = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.clif_match,
    ACTION_NAMES.lto_backend,
]

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

def _impl(ctx):
    tool_paths = [
        tool_path(
            name = "gcc",
            path = "bin/clang",
        ),
        tool_path(
            name = "ld",
            path = "bin/ld",
        ),
        tool_path(
            name = "ar",
            path = "bin/ar",
        ),
        tool_path(
            name = "cpp",
            path = "bin/clang++",
        ),
        tool_path(
            name = "gcov",
            path = "/bin/false",
        ),
        tool_path(
            name = "nm",
            path = "bin/nm",
        ),
        tool_path(
            name = "objdump",
            path = "bin/objdump",
        ),
        tool_path(
            name = "objcopy",
            path = "bin/objcopy",
        ),
        tool_path(
            name = "strip",
            path = "bin/strip",
        ),
    ]

    toolchain_include_directories_feature = feature(
        name = "toolchain_include_directories",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-isystem",
                            "external/%{repo_name}/toolchains/llvm-toolchain-archive/include/c++/v1",
                            "-isystem",
                            "external/%{repo_name}/toolchains/llvm-toolchain-archive/lib/clang/9.0.0/include",
                            "-isystem",
                            "external/%{repo_name}/toolchains/gcc-toolchain-archive/arm-none-eabi/include",
                        ],
                    ),
                ],
            ),
        ],
    )

    action_configs = [
        action_config(
            action_name = ACTION_NAMES.cpp_link_executable,
            tools = [
                tool(
                    path = "bin/gcc",
                ),
            ],
        ),
    ]

    default_link_flags_feature = feature(
        name = "default_link_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.cpp_link_executable,
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Wl,--gc-sections",
                            "-mcpu=cortex-m0",
                            "-mthumb",
                            "-fomit-frame-pointer",
                            "-gdwarf-2",
                            "-gstrict-dwarf",
                            "-mno-unaligned-access",
                            "-fno-common",
                            "-ffunction-sections",
                            "-fdata-sections",
                            "-fwhole-program",
                            "-nostartfiles",
                            "-lm",
                            "-lgcc",
                            "-lc",
                        ],
                    ),
                ],
            ),
        ],
    )

    default_compile_flags_feature = feature(
        name = "default_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.c_compile,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-O3",
                            "-Os",
                            "-fomit-frame-pointer",
                            "-momit-leaf-frame-pointer",
                            "-mno-unaligned-access",
                            "-gdwarf-2",
                            "-gstrict-dwarf",
                            "-fno-jump-tables",
                            "-fno-common",
                            "-mlittle-endian",
                            "-fdata-sections",
                            "-ffunction-sections",
                            "-funsigned-char",
                            "-fshort-enums",
                            "-nostdlib",
                            "-nodefaultlibs",
                            "-fropi",
                            "-no-canonical-prefixes",
                            # arch
                            "-mcpu=cortex-m0",
                            "-mthumb",
                            "--target=armv6m-none-eabi",
                            # Reproducibility
                            "-Wno-builtin-macro-redefined",
                            "-D__DATE__=\"redacted\"",
                            "-D__TIMESTAMP__=\"redacted\"",
                            "-D__TIME__=\"redacted\"",
                            # ledger sdk
                            "-DHAVE_BAGL",
                            "-DHAVE_SPRINTF",
                            "-DHAVE_IO_USB",
                            "-DHAVE_L4_USBLIB",
                            "-DHAVE_USB_APDU",
                            "-DHAVE_U2F",
                            "-DHAVE_IO_U2F",
                            "-DHAVE_UX_FLOW",
                            "-DOS_IO_SEPROXYHAL",
                            "-DU2F_PROXY_MAGIC=\"BOIL\"",
                            "-DUSB_SEGMENT_SIZE=64",
                            "-DBLE_SEGMENT_SIZE=32",
                            "-DIO_SEPROXYHAL_BUFFER_SIZE_B=128",
                            "-DIO_USB_MAX_ENDPOINTS=6",
                            "-DIO_HID_EP_LENGTH=64",
                            "-D__IO=volatile",
                            "-DNDEBUG",
                            "-DPRINTF(...)=",
                        ],
                    ),
                ],
            ),
        ],
    )

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "ledger-toolchain",
        host_system_name = "i686-unknown-linux-gnu",
        target_system_name = "arm",
        target_cpu = "arm",
        target_libc = "glibc",
        compiler = "clang",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
        features = [
            toolchain_include_directories_feature,
            default_link_flags_feature,
            default_compile_flags_feature,
        ],
        action_configs = action_configs,
    )

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)
