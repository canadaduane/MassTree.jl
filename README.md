# MassTree

[![Build Status](https://travis-ci.org/canadaduane/MassTree.jl.svg?branch=master)](https://travis-ci.org/canadaduane/MassTree.jl)

This package is a work in progress. It is a Julia wrapper for the extremely fast
MassTree key/value store and datastructure at https://github.com/kohler/masstree-beta.

See also [Eurosys 2012 Summary](http://highscalability.com/blog/2012/4/30/masstree-much-faster-than-mongodb-voltdb-redis-and-competiti.html).

## WIP

Some day, you will probably be able to install this with `Pkg.add`, but not today.

## Installation

If you still want to get it working, on Mac OS X:

1. add the files in this repository to your https://github.com/kohler/masstree-beta repository.

2. add the following to your GNUmakefile:
   ```
   all: test_atomics mtd mtclient mttest libmasstree.dylib
 
   libmasstree.dylib: masstree_wrapper.o misc.o checkpoint.o query_masstree.o \
     value_array.o value_versioned_array.o testrunner.o kvio.o log.o libjson.a
     @/bin/rm -f $@
     g++ -dynamiclib -undefined suppress -flat_namespace $^ -o libmasstree.dylib
   ```

3. put the libmasstree.dylib in the src folder along side MassTrees.jl

4. in Julia: `using MassTrees` will get you access to the `MassTree()` constructor

## Usage

```
mt = MassTree{String, String}()

for i in 1:10
  t["key$i"] = "string $(i*2)"
end

println("key1: $(t["key1"])")
println("key2: $(t["key2"])")
println("key3: $(t["key3"])")
println("key4: $(t["key4"])")
println("key5: $(t["key5"])")
```