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
