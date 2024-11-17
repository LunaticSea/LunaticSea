-- Patch table library
table.filter = function(t, func)
	local out = {}
	for k, v in pairs(t) do
		if func(v, k, t) then
			table.insert(out, v)
		end
	end
	return out
end

table.includes = function(t, e)
	for _, value in pairs(t) do
		if value == e then
			return e
		end
	end
	return nil
end

table.reduce = function(tbl, func, initial)
	local accumulator = initial
	for _, value in ipairs(tbl) do
		accumulator = func(accumulator, value)
	end
	return accumulator
end

-- Patch string library
string.split = function(string, pattern)
	local t = {}
	for i in string.gmatch(string, pattern) do
		t[#t + 1] = i
	end
	return t
end
