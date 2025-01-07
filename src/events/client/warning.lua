return function(client, warn)
  if warn == "Voice connection not initialized before VOICE_SERVER_UPDATE" then return end
  client.logd:warn('Discordia Warning', warn)
end
