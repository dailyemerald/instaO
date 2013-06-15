request = require 'request'

exports.getAuthURL = ->
    "https://api.instagram.com/oauth/authorize/?client_id=#{process.env.CLIENT_ID}&redirect_uri=#{credentials.callback_uri}&response_type=code"

exports.getDeleteURL = (subscriptionID) ->
    "https://api.instagram.com/v1/subscriptions?client_secret=#{process.env.CLIENT_SECRET}&id=#{subscriptionID}&client_id=#{process.env.CLIENT_ID}"

exports.getSubscriptionListURL = ->
    "https://api.instagram.com/v1/subscriptions?client_secret=#{process.env.CLIENT_SECRET}&client_id=#{process.env.CLIENT_ID}"

exports.getGeographyMediaRequest = (geographyID) ->
    "https://api.instagram.com/v1/geographies/#{geographyID}/media/recent?client_id=#{process.env.CLIENT_ID}"

exports.getTagMediaRequest = (tag_name) ->
    "https://api.instagram.com/v1/tags/#{tag_name}/media/recent?client_id=#{process.env.CLIENT_ID}"
  
exports.listSubscriptions = (callback) ->
  request {url: exports.getSubscriptionListURL}, (error, response, body) ->
    callback error, body

exports.buildGeographySubscription = (builder, subscriptionCallback) ->
  #builder = {
  #    lat: 10,
  #    lng: 10,
  #    radius: 1000,
  #    streamID: 'a stream id'
  #}
  requestObj = {
    method: 'POST',
    url: 'https://api.instagram.com/v1/subscriptions/',
    form: {
      'client_id': process.env.CLIENT_ID, 
      'client_secret': process.env.CLIENT_SECRET,
      'object': 'geography',
      'aspect': 'media', 
      'lat': builder.lat,
      'lng': builder.lng,
      'radius': builder.radius,
      'callback_url': process.env.CLIENT_SECRET + '/notify/' + builder.streamID #todo: get this out of hardcoding
    }
  }
  #console.log requestObj
  request requestObj, (error, response, body) ->
    if error is null
      subscriptionCallback null, '+ buildGeographySubscription'
    else
      subscriptionCallback '- error with buildSubscription!', null

exports.buildTagSubscription = (tag_name, subscriptionCallback) ->
    requestObj = {
      method: 'POST',
      url: 'https://api.instagram.com/v1/subscriptions/',
      form: {
        'client_id': process.env.CLIENT_ID, 
        'client_secret': process.env.CLIENT_SECRET,
        'object': 'tag',
        'aspect': 'media', 
        'object_id': tag_name
        'callback_url': "#{process.env.CALLBACK_URL}/notify/#{tag_name}",
      }
    }
    request requestObj, (error, response, body) ->
      if error is null
        subscriptionCallback null, '+ buildTagSubscription'
      else
        subscriptionCallback '- error with buildTagSubscription', null

exports.getTagMedia = (tag_name, callback) ->
  request exports.getTagMediaRequest(tag_name), (error, response, body) ->
    callback error, JSON.parse(body)

exports.getGeoMedia = (geographyID, callback) ->  
  request exports.getGeographyMediaRequest(geographyID), (error, response, body) ->     
    callback error, JSON.parse(body)
