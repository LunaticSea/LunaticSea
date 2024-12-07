local class = require('class')

local fruits = class:create('fruits')

function fruits:init(name)
  self.get_this = 'Hey, congrats :o'
  self.name = name
end

function fruits:entropy()
  return self.name .. '15052008'
end

local apple = class:create('apple', fruits)

function apple:init()
  self.name = 'apple'
  self.super('fruits', self.name)
end

function apple:hi()
  local data = self.parents.fruits:entropy()
  p(data)
  p(self.parents.fruits.get_this)
end

local end_class = apple:new()
end_class:hi()