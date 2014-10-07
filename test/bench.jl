using MassTree

timings = Dict()
function bm(T, name::String, n, prefix_len)
  t = T()
  println("Timing $T $name ($n keys) (key length $prefix_len)...")

  start = time_ns()
  key_strings = [randstring(prefix_len) for i in 1:n]
  finish = time_ns()

  l_name = "$name ($prefix_len) ($n) (gen)"
  get!(timings, l_name, Dict())
  timings[l_name][string(T)] = finish - start

  start = time_ns()
  for (i, s_prefix) in zip(1:n, key_strings)
    t[s_prefix] = string(i)
  end
  finish = time_ns()

  l_name = "$name ($prefix_len) ($n) (put)"
  get!(timings, l_name, Dict())
  timings[l_name][string(T)] = finish - start

  start = time_ns()
  for (i, s_prefix) in zip(1:n, key_strings)
    t[s_prefix]
  end
  finish = time_ns()

  l_name = "$name ($prefix_len) ($n) (get)"
  get!(timings, l_name, Dict())
  timings[l_name][string(T)] = finish - start
end

bm(MassTree{String,String}, "String:String", 100000, 5)
bm(MassTree{String,String}, "String:String", 100000, 50)
bm(MassTree{String,String}, "String:String", 100000, 500)
bm(MassTree{String,String}, "String:String", 1000000, 5)
bm(MassTree{String,String}, "String:String", 1000000, 50)
bm(MassTree{String,String}, "String:String", 1000000, 500)

bm(Dict, "String:String", 100000, 5)
bm(Dict, "String:String", 100000, 50)
bm(Dict, "String:String", 100000, 500)
bm(Dict, "String:String", 1000000, 5)
bm(Dict, "String:String", 1000000, 50)
bm(Dict, "String:String", 1000000, 500)

# println(timings)

println()
println("\t\t\t\t\t\tDict\t\tMassTree")
println("\t\t\t\t\t\t=========\t=========")
for name in sort(collect(keys(timings)))
  pairs = timings[name]
  print(name * "\t\t")
  for t in sort(collect(keys(pairs)))
    elapsed = pairs[t]
    print(string(elapsed/1000000000) * "\t")
  end
  println()
end

# t = MassTree{String, String}()
# n = 1000000
# s_prefix = "longkey"

# println("MassTree: Generating $n key::String/value::String pairs...")
# for i in 1:n
#   t[s_prefix * string(i)] = "$i"
# end

# println("MassTree: Fetching $n key/value pairs...")
# tic()
# for i in 1:n
#   t[s_prefix * string(i)];
# end
# toc()


# t = Dict()
# n = 1000000

# println("Dict: Generating $n key::String/value::String pairs...")
# tic()
# for i in 1:n
#   t[s_prefix * string(i)] = "$i"
# end
# toc()

# println("Dict: Fetching $n key/value pairs...")
# tic()
# for i in 1:n
#   t[s_prefix * string(i)];
# end
# toc()


# t = MassTree{String, Integer}()
# n = 1000000

# println("Generating $n key::String/value::Integer pairs...")
# tic()
# for i::Int32 in 1:n
#   t[string(i)] = i
# end
# toc()

# println("Fetching $n key/value pairs...")
# tic()
# for i::Int32 in 1:n
#   t[string(i)];
# end
# toc()

# t = MassTree{Integer, String}()
# n = 1000000

# println("Generating $n key::Integer/value::String pairs...")
# tic()
# for i::Int32 in 1:n
#   t[i] = "$i"
# end
# toc()

# println("Fetching $n key/value pairs...")
# tic()
# for i::Int32 in 1:n
#   t[i];
# end
# toc()

# t = MassTree{Integer, Integer}()
# n = 1000000

# println("Generating $n key::Integer/value::Integer pairs...")
# tic()
# for i::Int32 in 1:n
#   t[i] = i
# end
# toc()

# println("Fetching $n key/value pairs...")
# tic()
# for i::Int32 in 1:n
#   t[i];
# end
# toc()

