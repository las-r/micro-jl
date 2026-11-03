# micro-jl
A [micro](https://github.com/las-r/micro) interpreter written in Julia.

The subset this interpreter supports lacks importing capability.

## Building
Prerequisites: Julia, `PackageCompiler.jl`

```sh
git clone https://github.com/las-r/micro-jl.git
Rename-Item -Path "micro-jl" -NewName "Micro"
cd Micro
julia .\build.jl
```