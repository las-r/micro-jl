using PackageCompiler

create_app(
    @__DIR__,
    "build";
    executables = ["micro" => "julia_main"],
    filter_stdlibs = true,
    force = true,
    include_lazy_artifacts = false
)