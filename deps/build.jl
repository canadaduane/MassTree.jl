using BinDeps

@BinDeps.setup

@unix_only begin
  libmasstree = library_dependency("libmasstree", aliases = ["libmasstree"], os = :Unix)
end

# println("build.jl")
# println(libmasstree)

release = "f25186a8bf8a8aff3b630fa570e67f2e6d045c87"

provides(Sources,
  URI("https://github.com/kohler/masstree-beta/archive/$(release).zip"),
  [libmasstree], os=:Unix, unpacked_dir="masstree-beta-$(release)")

prefix = joinpath(BinDeps.depsdir(libmasstree), "usr")
srcdir = joinpath(BinDeps.depsdir(libmasstree), "src", "masstree-beta-$(release)")
libdir = joinpath(prefix, "lib")

provides(SimpleBuild,
(@build_steps begin
  GetSources(libmasstree)
  CreateDirectory(libdir)
  FileRule(joinpath(libdir, "libmasstree.dylib"), @build_steps begin
    ChangeDirectory(srcdir)
    `patch -f GNUmakefile.in ../../patch.diff`
    `cp ../../masstree_wrapper.cc ./`
    `./configure --disable-assertions --with-malloc=malloc CXX="clang++ -std=c++11 -stdlib=libc++"`
    `make libmasstree.dylib`
    `mkdir -p ../../usr/lib/`
    `cp libmasstree.dylib ../../usr/lib/`
  end)
end), [libmasstree], os=:Darwin)

@BinDeps.install [:libmasstree => :libmasstree]

# @ProTip
#
# For others looking to write build.jl files, I found the following resources helpful:
#
# The helpful BinDeps README, and JuliaLang Pkg manual:
# - https://github.com/JuliaLang/BinDeps.jl
# - http://julia.readthedocs.org/en/latest/manual/packages/
#
# Some nice examples, SCS being the most similar to MassTree's use case:
# - https://github.com/karanveerm/SCS.jl/blob/master/deps/build.jl
# - https://github.com/JuliaLang/Cairo.jl/blob/kf/bindeps2/deps/build.jl
# - https://github.com/JuliaLang/ZMQ.jl/blob/master/deps/build.jl
#
# Sometimes a look at the actual source code of BinDeps was useful:
# - https://github.com/JuliaLang/BinDeps.jl/blob/master/src/BinDeps.jl
#
# I found some of these resources by searching github for "build.jl" files with "@build_steps" in them:
# - https://github.com/search?utf8=%E2%9C%93&q=filename%3Abuild.jl+%22%40build_steps%22&type=Code&ref=searchresults
#