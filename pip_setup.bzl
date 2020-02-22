load("@rules_python//python:repositories.bzl", "py_repositories")
load("@rules_python//python:pip.bzl", "pip3_import", "pip_repositories")

def pip_setup():
    py_repositories()
    pip_repositories()

    # Create a central repo that knows about the dependencies needed for
    # requirements.txt.
    pip3_import(
        name = "pip_deps",
        requirements = "@%{repo_name}//:requirements.txt",
    )
