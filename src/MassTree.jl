module MassTree

  export MTDict

  if isfile(joinpath(Pkg.dir("MassTree"), "deps", "deps.jl"))
    include("../deps/deps.jl")
  else
    error("MassTree not properly installed. Please run Pkg.build(\"MassTree\") and restart julia")
  end

  typealias MasstreeWrapper Ptr{Void}

  type MTDict{Tk, Tv}
    masstree::MasstreeWrapper
    gc_store::ObjectIdDict
    function MTDict()
      masstree = mt_create()
      mt = new(masstree, ObjectIdDict())
      finalizer(mt, mt_destroy)
      mt
    end
  end

  function mt_destroy(mt::MTDict)
    ccall((:mt_destroy, libmasstree), Void, (Ptr{Void},), mt.masstree)
  end

  function mt_create()
    ccall((:mt_create, libmasstree), Ptr{Void}, ())
  end

  # String : String

  function mt_put(mt::MTDict{String, String}, key::String, value::String)
    ccall((:mt_put_str_str, libmasstree), Void, (Ptr{Void}, Ptr{Uint8}, Ptr{Uint8}), mt.masstree, key, value)
  end

  function mt_get(mt::MTDict{String, String}, key::String)
    value = ccall((:mt_get_str_str, libmasstree), Ptr{Uint8}, (Ptr{Void}, Ptr{Uint8}), mt.masstree, key)
    if value == C_NULL
      None
    else
      bytestring(value)
    end
  end

  # String : Integer

  function mt_put(mt::MTDict{String, Integer}, key::String, value::Int32)
    ccall((:mt_put_str_int, libmasstree), Void, (Ptr{Void}, Ptr{Uint8}, Cuint), mt.masstree, key, convert(Cuint, value))
  end

  function mt_get(mt::MTDict{String, Integer}, key::String)
    value = ccall((:mt_get_str_int, libmasstree), Ptr{Uint8}, (Ptr{Void}, Ptr{Uint8}), mt.masstree, key)
    if value == typemax(Uint32)
      None
    else
      value
    end
  end

  # Integer : String

  function mt_put(mt::MTDict{Integer, String}, key::Int32, value::String)
    ccall((:mt_put_int_str, libmasstree), Void, (Ptr{Void}, Cuint, Ptr{Uint8}), mt.masstree, key, value)
  end

  function mt_get(mt::MTDict{Integer, String}, key::Int32)
    value = ccall((:mt_get_int_str, libmasstree), Ptr{Uint8}, (Ptr{Void}, Cuint), mt.masstree, key)
    if value == C_NULL
      None
    else
      bytestring(value)
    end
  end

  # Integer : Integer

  function mt_put(mt::MTDict{Integer, Integer}, key::Int32, value::Int32)
    ccall((:mt_put_int_int, libmasstree), Void, (Ptr{Void}, Cuint, Cuint), mt.masstree, key, value)
  end

  function mt_get(mt::MTDict{Integer, Integer}, key::Int32)
    value = ccall((:mt_get_int_int, libmasstree), Ptr{Uint8}, (Ptr{Void}, Cuint), mt.masstree, key)
    if value == typemax(Uint32)
      None
    else
      value
    end
  end


  getindex(mt::MTDict, key) = mt_get(mt, key)
  setindex!(mt::MTDict, value, key) = mt_put(mt, key, value)

end