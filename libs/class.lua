--[[lit-meta
  name = "LunaticSea/class"
  version = "2.0.4"
  license = "AGPL-v3.0"
  homepage = "https://github.com/LunaticSea/LunaticSea/blob/master/libs/class.lua"
  description = "Core object model for luvit using simple prototypes and inheritance."
  tags = {"luvit", "objects", "inheritance"}
]]
local class = {}

--[[
Returns whether obj is instance of class or not.

    local object = Object:new()
    local emitter = Emitter:new()

    assert(instanceof(object, Object))
    assert(not instanceof(object, Emitter))

    assert(instanceof(emitter, Object))
    assert(instanceof(emitter, Emitter))

    assert(not instanceof(2, Object))
    assert(not instanceof('a', Object))
    assert(not instanceof({}, Object))
    assert(not instanceof(function() end, Object))

Caveats: This function returns true for classes.
    assert(instanceof(Object, Object))
    assert(instanceof(Emitter, Object))
]]
function class.instanceof(obj, target_class)
  if type(obj) ~= 'table' or obj.meta == nil or not target_class then
    return false
  end
  if obj.meta.__index == target_class then
    return true
  end
  local meta = obj.meta
  while meta do
    if meta.super == target_class then
      return true
    elseif meta.super == nil then
      return false
    end
    meta = meta.super.meta
  end
  return false
end

--------------------------------------------------------------------------------

--[[
This is the most basic object in Luvit. It provides simple prototypal
inheritance and inheritable constructors. All other objects inherit from this.
]]
class.meta = {__index = class}

-- Create a new instance of this object
function class:_create()
  local meta = rawget(self, "meta")
  if not meta then error("Cannot inherit from instance object") end
  return setmetatable({}, meta)
end

--[[
Creates a new instance and calls `obj:init(...)` if it exists.

    local Rectangle = Object:extend()
    function Rectangle:init(w, h)
      self.w = w
      self.h = h
    end
    function Rectangle:getArea()
      return self.w * self.h
    end
    local rect = Rectangle:new(3, 4)
    p(rect:getArea())
]]
function class:new(...)
  local obj = self:_create()
  if type(obj.init) == "function" then
    obj:init(...)
  end
  return obj
end

--[[
Creates a new sub-class.
    local Square = Rectangle:extend()
    function Square:init(w)
      self.w = w
      self.h = h
    end
]]

function class:create()
  local obj = self:_create()
  local meta = {}
  -- move the meta methods defined in our ancestors meta into our own
  --to preserve expected behavior in children (like __tostring, __add, etc)
  for k, v in pairs(self.meta) do
    meta[k] = v
  end
  meta.__index = obj
  meta.super = self
  obj.meta = meta
  return obj
end

return class
