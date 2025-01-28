return [[
bot:
  # ---------------------   TOKEN is important!!!!   ---------------------
  TOKEN: 'Bot Token 1'
  # ---------------------   TOKEN is important!!!!   ---------------------

  # ---------------------  OWNER_ID is important!!!  ---------------------
  OWNER_ID: 'Your User ID'
  # ---------------------  OWNER_ID is important!!!  ---------------------

  EMBED_COLOR: '#2B2D31'
  ADMIN: ['<your_trusted_admin_discord_id_here>']
  # You can set it to en, vi...
  LANGUAGE: 'en'
  DEBUG_MODE: false

player:
  SPOTIFY:
    # Your Spotify ID and Secret, you can get it from here: https://developer.spotify.com
    # If you don't have or don't want, you can disable it
    enable: false
    id: ''
    secret: ''

  # Default search suggestion for auto complete, leave it empty will use default
  AUTOCOMPLETE_SEARCH: ['yorushika', 'yoasobi', 'tuyu', 'hinkik']

  # The amount of time before the bot leaves the VC in milliseconds
  LEAVE_TIMEOUT: 60000

  # Must not over 1000 or bot crash
  DEFAULT_VOLUME: 100

  # Enable this to avoid your bot get suspended (Recommended to be enable)
  AVOID_SUSPEND: true

  # The number of tracks you want to limit
  LIMIT_TRACK: 50

  # The number of playlist you want to limit
  LIMIT_PLAYLIST: 20

  # You can add more Lavalink servers!
  # ---------------------  NODES is important!!!  ---------------------
  NODES:
    - host: 'IP'
      port: 2333 # Your host port here
      name: 'Name' #only a-z A-Z 0-9 and _
      auth: 'Password'
      secure: false
      # In rainlink, it support lavalink v3, lavalink v4 and nodelink v2 as driver
      # If you put the wrong driver identify here or not put anything here,
      # it will fallback to lavalink v4 driver
      # Driver identify and support range:
      # | Type     | Support versions | Driver Name |
      # | -------- | ---------------- | ----------- |
      # | Lavalink | v4.0.0 - v4.x.x  | koinu       |
      # | Lavalink | v3.0.0 - v3.7.x  | koto        |
      # | Nodelink | v2.0.0 - v2.x.x  | nari        |
      driver: 'lavalink@4'
  # ---------------------  NODES is important!!!  ---------------------

utilities:
  # Log register premium activities
  PREMIUM_LOG_CHANNEL: ''
  # Log all the guild that bot joined or leaved
  GUILD_LOG_CHANNEL: ''
  # Log all unhandled, error, warnings on discord
  LOG_CHANNEL: ''
  # The timeout for deleting msg in milliseconds
  DELETE_MSG_TIMEOUT: 3000

  # Database services config
  DATABASE:
    # Note: If you enter an invalid driver, bot will use csv driver as default
    # Config key must same as driver name
    driver: 'csv' # csv, rethink
    csv:
      file_name: 'lunatic.db.csv'
    rethink:
      host: '127.0.0.1'
      port: 28015
      username: 'admin'
      password: ''
      database: 'test'
      logLevel: 0

  # Msg content for bot using prefix command and setup
  MESSAGE_CONTENT:
    enable: true
    # Whenever you want to use prefix command or not
    commands:
      enable: true
      prefix: 'd!' # The prefix you want

# You can custom your emoji here!
emojis:
  PLAYER:
    play: '▶️'
    pause: '⏸️'
    loop: '🔁'
    shuffle: '🔀'
    stop: '⏹️'
    skip: '⏩'
    previous: '⏪'
    voldown: '🔉'
    volup: '🔊'
    queue: '📋'
    delete: '🗑'
  GLOBAL:
    arrow_next: '➡'
    arrow_previous: '⬅'

# Note:
# You can delete all config above and uncomment this for load default config
# bot:
#   TOKEN: 'Bot Token 1'
#   OWNER_ID: 'Your User ID'

# player:
#   NODES:
#     - host: 'IP'
#       port: 2333
#       name: 'Name'
#       auth: 'Password'
#       secure: false
#       driver: 'lavalink@4'
]]