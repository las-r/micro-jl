using PackageCompiler

create_app(
    @__DIR__,
    "build";
    executables = ["micro" => "julia_main"]
)