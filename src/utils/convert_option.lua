return function(data)
  if data.type == 6 then return string.format('<@%s>', data.value) end
  if data.type == 8 then return string.format('<@&%s>', data.value) end
  if data.type == 7 then return string.format('<#%s>', data.value) else return 'error' end
end