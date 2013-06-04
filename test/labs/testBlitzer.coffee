Blitzer = require '../src/blitzer'

blitzer = new Blitzer 'software@cdsm.co.uk', '8085cffe-45fefbe5-628f83bb-484295ee', blitz: '-r ireland http://www.cdsm.co.uk'

blitzer.run ->
	console.log "Blitz complete"