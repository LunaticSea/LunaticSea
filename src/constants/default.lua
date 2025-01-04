return {
	bot = {
		TOKEN = '',
		OWNER_ID = '',
		EMBED_COLOR = '#2B2D31',
		LANGUAGE = 'en',
		DEBUG_MODE = false,
		ADMIN = {},
	},
	player = {
		SPOTIFY = {
			enable = false,
			id = '',
			secret = '',
		},
		AUTOCOMPLETE_SEARCH = { 'yorushika', 'yoasobi', 'tuyu', 'hinkik' },
		NP_REALTIME = false,
		LEAVE_TIMEOUT = 30000,
		NODES = {},
		DEFAULT_VOLUME = 100,
		AVOID_SUSPEND = false,
		LIMIT_TRACK = 50,
		LIMIT_PLAYLIST = 20,
	},
	utilities = {
		PREFIX = 'd!',
		DATABASE = {
			driver = 'csv',
			csv = { file_name = 'lunatic.db.csv' },
		},
		AUTO_RESUME = false,
		TOPGG_TOKEN = '',
		DELETE_MSG_TIMEOUT = 2000,
		SHARDING_SYSTEM = {
			shardsPerClusters = 2,
			totalClusters = 2,
		},
		MESSAGE_CONTENT = {
			enable = true,
			commands = {
				enable = true,
				prefix = 'd!',
			},
		},
		AUTOFIX_LAVALINK = {
			enable = true,
			retryCount = 10,
			retryTimeout = 3000,
		},
		WEB_SERVER = {
			host = '0.0.0.0',
			enable = false,
			port = 2880,
			auth = 'youshallnotpass',
			whitelist = {},
		},
		PREMIUM_LOG_CHANNEL = '',
		GUILD_LOG_CHANNEL = '',
		LOG_CHANNEL = '',
	},
	icons = {
	  PLAYER = {
	    play = '▶️',
      pause = '⏸️',
      loop = '🔁',
      shuffle = '🔀',
      stop = '⏹️',
      skip = '⏩',
      previous = '⏪',
      voldown = '🔉',
      volup = '🔊',
      queue = '📋',
      delete = '🗑',
	  },
	  GLOBAL = {
      arrow_next = '➡',
      arrow_previous = '⬅',
    }
	}
}
