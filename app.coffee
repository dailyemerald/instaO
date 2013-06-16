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

app.get '/stats', (req, res) ->
	res.json process.memoryUsage()

instagram.getTagMedia 'goducks', (err, photos) ->
	console.log "got #{photos.length} photos back"
	console.log photos
	last_set = photos.data

update_tag_media = (object_id) ->
	instagram.getTagMedia object_id, (err, data) ->
		last_set = data.data
		io.sockets.emit 'bootstrap', last_set #TODO: refactor
		console.log('tag', data)

update_geo_media = (object_id) ->
	instagram.getGeoMedia object_id, (err, data) ->
		last_set = data.data
		io.sockets.emit 'bootstrap', last_set #TODO: refactor
		console.log('geo', data)


app.get '/notify/:id', (req, res) -> # confirm the subscription
	if req.query and req.query['hub.mode'] is 'subscribe'
		console.log "Confirming new Instagram real-time subscription for #{req.params.id} with #{req.query['hub.challenge']}"
		res.send req.query['hub.challenge'] 
	else
		console.log "Weird request to /notify, didn't have a hub.mode..."

app.post '/notify/:id', (req, res) -> # receive the webhook, we got a new photo!
	notifications = req.body
	console.log 'Notification for', req.params.id # '. Had', notifications.length, 'item(s). Subscription ID:', req.body[0].subscription_id
	console.log notifications

	for notification in notifications
		update_tag_media(notification.object_id) if notification.object is "tag"	        
		update_geo_media(notification.object_id) if notification.object is "geo"	        

	res.send 200

app.get '/list', (req, res) ->
	instagram.listSubscriptions (err, resp, data) ->
		res.json [err, resp, data]

app.get '/build', (req, res) ->
	instagram.buildTagSubscription 'goducks', (err, data) ->
		res.json {err: err, data: data}









# blah blah blah below

#app.get '/push_test', (req, res) ->
#	res.send 200, ''
#	io.sockets.emit 'new', instagram.example_photo	
