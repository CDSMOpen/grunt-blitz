winston = require 'winston'

levels = 
	build: 1
	info: 2
	warn: 3
	error: 4

colors = 
	build: 'white'
	info: 'green'
	warn: 'yellow'
	error: 'red'

buildLogger = new winston.Logger {
	levels: levels
	colors: colors
	transports: [
		new winston.transports.Console {
			colorize: true
			level: 'build'
		}
		new winston.transports.File {
			filename: './test/labs/error.log'
			colorize: false
			json: false
		}
	]
}

# winston.loggers.add 'build', {
# 	console: {
# 		colorize: false
# 		label: 'build messages'
# 		levels: levels
# 	}
# 	file: {
# 		filename: './error.log'
# 		level: 'error'
# 		colorize: 'false'
# 	}
# }

logger = buildLogger
logger.info 'This is some info'
logger.warn 'watch out'
logger.build 'this is a build message \n##teamcity[testStarted]'
logger.error 'This is an error'