package(
    default_visibility = ["//visibility:public"],
)

constraint_setting(name = "device")

constraint_value(
    name = "nanos-device",
    constraint_setting = ":device",
)

constraint_value(
    name = "nanox-device",
    constraint_setting = ":device",
)

platform(
    name = "nanos",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:arm",
        ":nanos-device",
    ],
)

platform(
    name = "nanox",
    constraint_values = [
        ":nanox-device",
    ],
)
