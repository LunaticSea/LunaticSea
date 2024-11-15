local core = {}

-- database -> key -> data

function core:new(options)
  self.cache = {}
  options = options or {}
  self.db_name = options.db_name or 'lunatic_db'
  self.cache[self.db_name] = {}
  return self
end

function core:set(key, data)
  assert(self.cache[self.db_name], "This database doesn't exist")
  self.cache[self.db_name][key] = data
  return data
end

function core:get(key)
  assert(self.cache[self.db_name], "This database doesn't exist")
  return self.cache[self.db_name][key]
end

function core:delete(key)
  assert(self.cache[self.db_name], "This database doesn't exist")
  local deleted_data = self.cache[self.db_name][key]
  self.cache[self.db_name][key] = nil
  return {
    data = deleted_data,
    key = key
  }
end

function core:delete_all(db_name)
  if db_name then
    self.cache[db_name] = {}
  else
    self.cache[self.db_name] = {}
  end
  return nil
end

function core:all()
  return self.cache[self.db_name]
end

function core:drop_db(db_name)
  if db_name then
    self.cache[db_name] = nil
  else
    self.cache[self.db_name] = nil
  end
  return nil
end

function core:switch_db(db_name)
  local is_exist = self.cache[db_name]
  assert(is_exist, "This database doesn't exist")
  self.db_name = db_name
  return true
end

function core:create_db(db_name)
  self.cache[db_name] = {}
  self.db_name = db_name
  return true
end

return core