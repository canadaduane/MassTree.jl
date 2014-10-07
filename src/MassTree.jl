module MassTree

  const _libmasstree = "libmasstree"

  typealias MasstreeWrapper Ptr{Void}

  export MassTree

  type MassTree{Tk, Tv}
    masstree::MasstreeWrapper
    gc_store::ObjectIdDict
    function MassTree()
      masstree = mt_create()
      mt = new(masstree, ObjectIdDict())
      finalizer(mt, mt_destroy)
      mt
    end
  end

  function mt_destroy(mt::MassTree)
    ccall((:mt_destroy, _libmasstree), Void, (Ptr{Void},), mt.masstree)
  end

  function mt_create()
    ccall((:mt_create, _libmasstree), Ptr{Void}, ())
  end

  # String : String

  function mt_put(mt::MassTree{String, String}, key::String, value::String)
    ccall((:mt_put_str_str, _libmasstree), Void, (Ptr{Void}, Ptr{Uint8}, Ptr{Uint8}), mt.masstree, key, value)
  end

  function mt_get(mt::MassTree{String, String}, key::String)
    value = ccall((:mt_get_str_str, _libmasstree), Ptr{Uint8}, (Ptr{Void}, Ptr{Uint8}), mt.masstree, key)
    if value == C_NULL
      None
    else
      bytestring(value)
    end
  end

  # String : Integer

  function mt_put(mt::MassTree{String, Integer}, key::String, value::Int32)
    ccall((:mt_put_str_int, _libmasstree), Void, (Ptr{Void}, Ptr{Uint8}, Cuint), mt.masstree, key, convert(Cuint, value))
  end

  function mt_get(mt::MassTree{String, Integer}, key::String)
    value = ccall((:mt_get_str_int, _libmasstree), Ptr{Uint8}, (Ptr{Void}, Ptr{Uint8}), mt.masstree, key)
    if value == typemax(Uint32)
      None
    else
      value
    end
  end

  # Integer : String

  function mt_put(mt::MassTree{Integer, String}, key::Int32, value::String)
    ccall((:mt_put_int_str, _libmasstree), Void, (Ptr{Void}, Cuint, Ptr{Uint8}), mt.masstree, key, value)
  end

  function mt_get(mt::MassTree{Integer, String}, key::Int32)
    value = ccall((:mt_get_int_str, _libmasstree), Ptr{Uint8}, (Ptr{Void}, Cuint), mt.masstree, key)
    if value == C_NULL
      None
    else
      bytestring(value)
    end
  end

  # Integer : Integer

  function mt_put(mt::MassTree{Integer, Integer}, key::Int32, value::Int32)
    ccall((:mt_put_int_int, _libmasstree), Void, (Ptr{Void}, Cuint, Cuint), mt.masstree, key, value)
  end

  function mt_get(mt::MassTree{Integer, Integer}, key::Int32)
    value = ccall((:mt_get_int_int, _libmasstree), Ptr{Uint8}, (Ptr{Void}, Cuint), mt.masstree, key)
    if value == typemax(Uint32)
      None
    else
      value
    end
  end


  getindex(mt::MassTree, key) = mt_get(mt, key)
  setindex!(mt::MassTree, value, key) = mt_put(mt, key, value)

end