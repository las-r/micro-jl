# micro-jl
A [micro](https://github.com/las-r/micro) interpreter written in Julia.

The subset this interpreter supports lacks importing capability, similar to [microbe](https://github.com/las-r/microbe).

## Building
Prerequisites: Julia, `PackageCompiler.jl`

```sh
git clone https://github.com/las-r/micro-jl.git
ren "micro-jl" "Micro"
cd Micro
julia .\build.jl
```
