# MassTree

[![Build Status](https://travis-ci.org/canadaduane/MassTree.jl.svg?branch=master)](https://travis-ci.org/canadaduane/MassTree.jl)

This package is a work in progress. It is a Julia wrapper for the extremely fast
MassTree key/value store and datastructure at https://github.com/kohler/masstree-beta.
It currently compiles on Mac OS X.

See also [Eurosys 2012 Summary](http://highscalability.com/blog/2012/4/30/masstree-much-faster-than-mongodb-voltdb-redis-and-competiti.html).

## Installation

`Pkg.clone("git://github.com/canadaduane/MassTree.jl.git")`

## Usage

```
using MassTree

mt = MTDict{String, String}()

for i in 1:10
  t["key$i"] = "string $(i*2)"
end

println("key1: $(t["key1"])")
println("key2: $(t["key2"])")
println("key3: $(t["key3"])")
println("key4: $(t["key4"])")
println("key5: $(t["key5"])")
# ...
```