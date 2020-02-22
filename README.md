# Ledger Toolchain and SDK for bazel

This repo contains a set of toolchains and helper rules for building [Ledger](https://ledger.readthedocs.io/en/latest/) apps with the [bazel](https://bazel.build/) build system.

The provided rules will automatically install and configure the build environment for compiling ledger apps on your host system. The installed toolchain is isolated from your system for consistent and reproducible builds across development environments.

In addition to toolchain setup, the rules expose a `ledger_app` macro. This macro sets up the cc_binary and icon build rules for your app.

## Requirements

The toolchain rules will download and install the compiler and python dependencies. The following tools and dependencies must be installed manually.

- [bazel](https://docs.bazel.build/versions/master/install.html) version 2.1 or higher
- Python 3

## Example

Your `WORKSPACE` file should contain the following

```python
workspace(
    name = "my_ledger_app",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "sdk_bootstrap",
    strip_prefix = "bazel-ledger-sdk-v1.6.0-0",
    urls = ["https://gitlab.com/polychainlabs/bazel-ledger-sdk/-/archive/v1.6.0-0/bazel-ledger-sdk-v1.6.0-0.tar.gz"]
)

# Initialize the ledger sdk rules
# This will download the clang and gcc toolchains and configure the build environment
load("@sdk_bootstrap//:rules.bzl", "ledger_sdk")
ledger_sdk(
    name = "ledgersdk",
)

# GIF icon conversion requires python, this will setup the environment to build icons
load("@ledgersdk//:pip_setup.bzl", "pip_setup")
pip_setup()

# Install dependencies for building icons
load("@ledgersdk//:pip_install.bzl", "pip_install")
pip_install()
```

Your `BUILD` file should contain the following:

```python
load("@ledgersdk//:app.bzl", "ledger_app")

ledger_app(
    name = "app",
    srcs = [
        "src/main.c",
    ],
    icons = [
        "icons/icon_up.gif",
        "icons/icon_down.gif",
    ],
)
```

And finally, you should have a `.bazelrc` file containing

```bazel
build --experimental_strict_action_env=true
build --incompatible_enable_cc_toolchain_resolution
build --platforms=@ledgersdk//platforms:nanos
```

### Build your project

```shell
bazel build //...
```
