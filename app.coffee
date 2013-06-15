express = require('express')
app = express()
server = app.listen(process.env.PORT || 5000)
io = require('socket.io').listen(server)
instagram = require './instagram'

last_set = []

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'ejs'  
  app.use express.static(__dirname + "/public")
  app.use express.bodyParser()
  app.use express.cookieParser()

io.set('log level', 1)

io.configure ->
	io.set("transports", ["xhr-polling"])
	io.set("polling duration", 10)

io.on 'connection', (socket) ->
	socket.emit 'bootstrap', last_set

app.get '/mem', (req, res) ->
	res.json process.memoryUsage()

instagram.getTagMedia 'goducks', (err, photos) ->
	console.log "got #{photos.length} photos back"
	console.log photos
	last_set = photos.data