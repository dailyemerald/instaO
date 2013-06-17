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

db_doesnt_include = (id) ->
	for item in last_set
		return false if item.id == id
	return true

insert_if_new = (photo) ->
	if db_doesnt_include(last_set, photo.id)
		console.log("+ YES new: #{photo.id}")
		last_set.push photo
		io.sockets.emit 'new', photo
	else
		console.log("- NOT new: #{photo.id}")

update_tag_media = (object_id) ->
	console.log('update_tag_media')
	instagram.getTagMedia object_id, (err, data) ->
		for photo in data.data
			insert_if_new(photo)		
		#console.log('tag', data)

update_geo_media = (object_id) ->
	console.log('update_geo_media')
	instagram.getGeoMedia object_id, (err, data) ->
		for photo in data.data
			insert_if_new(photo)
		#console.log('geo', data)

app.get '/notify', (req, res) -> # confirm the subscription
	if req.query and req.query['hub.mode'] is 'subscribe'
		console.log "Confirming new Instagram real-time subscription for #{req.params.id} with #{req.query['hub.challenge']}"
		res.send req.query['hub.challenge'] 
	else
		console.log "Weird request to /notify, didn't have a hub.mode..."

app.post '/notify/:id', (req, res) -> # receive the webhook, we got a new photo!
	console.log 'Notification for', req.params.id # '. Had', notifications.length, 'item(s). Subscription ID:', req.body[0].subscription_id
	console.log req.body
	for notification in req.body
		update_tag_media(notification.object_id) if notification.object is "tag"	        
		update_geo_media(notification.object_id) if notification.object is "geo"	        
	res.send 200

app.get '/list', (req, res) ->
	console.log '/list'
	instagram.listSubscriptions (err, resp, data) ->
		res.json [err, resp, data]

update_geo_media('3503334')
update_tag_media('goducks')







# blah blah blah below

#app.get '/push_test', (req, res) ->
#	res.send 200, ''
#	io.sockets.emit 'new', instagram.example_photo	
