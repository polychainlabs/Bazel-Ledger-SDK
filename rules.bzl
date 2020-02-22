load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_distributions = {
    "darwin": {
        "llvm": {
            "url": "https://releases.llvm.org/9.0.0/clang+llvm-9.0.0-x86_64-darwin-apple.tar.xz",
            "sha256": "b46e3fe3829d4eb30ad72993bf28c76b1e1f7e38509fbd44192a2ef7c0126fc7",
            "strip_prefix": "clang+llvm-9.0.0-x86_64-darwin-apple",
        },
        "gcc": {
            "url": "https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-mac.tar.bz2",
            "sha256": "1249f860d4155d9c3ba8f30c19e7a88c5047923cea17e0d08e633f12408f01f0",
            "strip_prefix": "gcc-arm-none-eabi-9-2019-q4-major",
        },
    },
    "linux": {
        "llvm": {
            "url": "https://releases.llvm.org/9.0.0/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz",
            "sha256": "a23b082b30c128c9831dbdd96edad26b43f56624d0ad0ea9edec506f5385038d",
            "strip_prefix": "clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04",
        },
        "gcc": {
            "url": "https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2",
            "sha256": "bcd840f839d5bf49279638e9f67890b2ef3a7c9c7a9b25271e83ec4ff41d177a",
            "strip_prefix": "gcc-arm-none-eabi-9-2019-q4-major",
        },
    },
}

def download_toolchains(rctx):
    python3 = rctx.which("python3")
    if not python3:
        fail("python3 is required")

    exec_result = rctx.execute([
        python3,
        rctx.path("host_facts.py"),
    ])

    if exec_result.return_code:
        fail("Failed to detect host OS version: \n%s\n%s" % (exec_result.stdout, exec_result.stderr))
    if exec_result.stderr:
        print(exec_result.stderr)
    basename = exec_result.stdout.strip()
    distr = _distributions[basename]

    rctx.download_and_extract(
        [distr["llvm"]["url"]],
        sha256 = distr["llvm"]["sha256"],
        stripPrefix = distr["llvm"]["strip_prefix"],
        output = "toolchains/llvm-toolchain-archive",
    )

    rctx.download_and_extract(
        [distr["gcc"]["url"]],
        sha256 = distr["gcc"]["sha256"],
        stripPrefix = distr["gcc"]["strip_prefix"],
        output = "toolchains/gcc-toolchain-archive",
    )

    rctx.symlink(
        "toolchains/llvm-toolchain-archive/bin/clang",
        "toolchains/bin/clang",
    )

    rctx.symlink(
        "toolchains/llvm-toolchain-archive/bin/clang++",
        "toolchains/bin/clang++",
    )

    rctx.symlink(
        "toolchains/llvm-toolchain-archive/bin/llvm-ar",
        "toolchains/bin/ar",
    )

    rctx.symlink(
        "toolchains/llvm-toolchain-archive/bin/llvm-nm",
        "toolchains/bin/nm",
    )

    rctx.symlink(
        "toolchains/llvm-toolchain-archive/bin/llvm-objdump",
        "toolchains/bin/objdump",
    )

    rctx.symlink(
        "toolchains/llvm-toolchain-archive/bin/llvm-strip",
        "toolchains/bin/strip",
    )

    rctx.symlink(
        "toolchains/gcc-toolchain-archive/bin/arm-none-eabi-gcc",
        "toolchains/bin/gcc",
    )

    rctx.symlink(
        "toolchains/gcc-toolchain-archive/bin/arm-none-eabi-ld",
        "toolchains/bin/ld",
    )

    rctx.symlink(
        "toolchains/gcc-toolchain-archive/bin/arm-none-eabi-objcopy",
        "toolchains/bin/objcopy",
    )

# https://docs.bazel.build/versions/master/skylark/lib/repository_ctx.html
def _impl(rctx):
    substitutions = {
        "%{repo_name}": rctx.name,
    }

    rctx.file("BUILD")

    rctx.template(
        "host_facts.py",
        Label("//:host_facts.py"),
        substitutions,
    )

    rctx.template(
        "sdk/BUILD",
        Label("//:sdk.BUILD.tpl"),
        substitutions,
    )

    rctx.template(
        "app.bzl",
        Label("//:app.bzl.tpl"),
        substitutions,
    )

    rctx.template(
        "pip_setup.bzl",
        Label("//:pip_setup.bzl"),
        substitutions,
    )

    rctx.template(
        "pip_install.bzl",
        Label("//:pip_install.bzl"),
        substitutions,
    )

    rctx.template(
        "toolchains/BUILD",
        Label("//:toolchains.BUILD"),
        substitutions,
    )

    rctx.template(
        "platforms/BUILD",
        Label("//:platforms.BUILD"),
        substitutions,
    )

    rctx.template(
        "toolchains/cc_toolchain_config.bzl",
        Label("//:cc_toolchain_config.bzl"),
        substitutions,
    )

    rctx.download_and_extract(
        url = "https://github.com/LedgerHQ/nanos-secure-sdk/archive/nanos-160.tar.gz",
        output = "sdk",
        stripPrefix = "nanos-secure-sdk-nanos-160",
        sha256 = "3a3f96c1cdb3caf297575a0e9c209aea329c0469f7f6a39b40141d8c6e85e683",
    )

    rctx.patch(
        Label("//:changes.patch"),
        strip = 1,
    )

    download_toolchains(rctx)

_ledger_sdk = repository_rule(
    implementation = _impl,
    local = False,
    attrs = {},
)

def ledger_sdk(name = None):
    http_archive(
        name = "rules_python",
        url = "https://github.com/bazelbuild/rules_python/archive/38f86fb55b698c51e8510c807489c9f4e047480e.tar.gz",
        sha256 = "c911dc70f62f507f3a361cbc21d6e0d502b91254382255309bc60b7a0f48de28",
        strip_prefix = "rules_python-38f86fb55b698c51e8510c807489c9f4e047480e",
    )

    native.register_toolchains(
        "@%s//toolchains:cc-toolchain-ledger-osx" % (name),
        "@%s//toolchains:cc-toolchain-ledger-linux" % (name),
    )

    _ledger_sdk(
        name = name,
    )
