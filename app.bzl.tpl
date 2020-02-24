def ledger_app(name, srcs = [], deps = [], icons = [], copts = []):
    native.genrule(
        name = "glyphsh",
        srcs = icons,
        outs = ["glyphs.h"],
        cmd = '$(location @%{repo_name}//sdk:icon3) --glyphcheader $(SRCS) > $@',
        tools = ['@%{repo_name}//sdk:icon3'],
    )

    native.genrule(
        name = "glyphsc",
        srcs = icons,
        outs = ["glyphs.c"],
        cmd = '$(location @%{repo_name}//sdk:icon3) --glyphcfile $(SRCS) > $@',
        tools = ['@%{repo_name}//sdk:icon3'],
    )

    native.cc_library(
        name = "glyphlib",
        srcs = [],
        hdrs = [":glyphsh"],
        include_prefix = ".",
    )

    native.cc_binary(
        name = name,
        srcs = srcs + [":glyphsc"],
        deps = [
            "@%{repo_name}//sdk:sdk",
            ":glyphlib",
        ] + deps,
        copts = [
            "-std=gnu18",
            "-Wall",
            "-Werror",
        ] + copts,
    )