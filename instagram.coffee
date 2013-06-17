request = require 'request'

exports.getAuthURL = ->
    "https://api.instagram.com/oauth/authorize/?client_id=#{process.env.CLIENT_ID}&redirect_uri=#{process.env.CALLBACK_URL}&response_type=code"

exports.getDeleteURL = (subscriptionID) ->
    "https://api.instagram.com/v1/subscriptions?client_secret=#{process.env.CLIENT_SECRET}&id=#{subscriptionID}&client_id=#{process.env.CLIENT_ID}"

exports.getGeographyMediaRequest = (geographyID) ->
    "https://api.instagram.com/v1/geographies/#{geographyID}/media/recent?client_id=#{process.env.CLIENT_ID}"

exports.getTagMediaRequest = (tag_name) ->
    "https://api.instagram.com/v1/tags/#{tag_name}/media/recent?client_id=#{process.env.CLIENT_ID}"
  
exports.listSubscriptions = (callback) ->
  requestObj = {
    url: "https://api.instagram.com/v1/subscriptions?client_secret=#{process.env.CLIENT_SECRET}&client_id=#{process.env.CLIENT_ID}"
  }
  console.log requestObj
  request requestObj, (error, response, body) ->
    callback error, response, body

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
      'callback_url': process.env.CALLBACK_URL + '/notify/' + builder.streamID #todo: get this out of hardcoding
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
      console.log(error, response, body);
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




exports.example_photo = {
  "attribution": null,
  "tags": [
    "goducks",
    "denverbound",
    "oddcouple"
  ],
  "location": null,
  "comments": {
    "count": 0,
    "data": []
  },
  "filter": "Earlybird",
  "created_time": "1371343264",
  "link": "http://instagram.com/p/amZ8D5rzhB/",
  "likes": {
    "count": 5,
    "data": [
      {
        "username": "emilyangulo",
        "profile_picture": "http://images.ak.instagram.com/profiles/profile_17055232_75sq_1371162045.jpg",
        "id": "17055232",
        "full_name": "emilyangulo"
      },
      {
        "username": "society43",
        "profile_picture": "http://images.ak.instagram.com/profiles/profile_198486160_75sq_1368141317.jpg",
        "id": "198486160",
        "full_name": "society43"
      },
      {
        "username": "jiron90",
        "profile_picture": "http://images.ak.instagram.com/profiles/profile_180962500_75sq_1362498017.jpg",
        "id": "180962500",
        "full_name": "Adolfo Cuadra"
      },
      {
        "username": "janelllee_",
        "profile_picture": "http://images.ak.instagram.com/profiles/profile_29781613_75sq_1368210863.jpg",
        "id": "29781613",
        "full_name": "Janelle 💄"
      }
    ]
  },
  "images": {
    "low_resolution": {
      "url": "http://distilleryimage1.s3.amazonaws.com/6cc77b32d61d11e28ab422000aa80430_6.jpg",
      "width": 306,
      "height": 306
    },
    "thumbnail": {
      "url": "http://distilleryimage1.s3.amazonaws.com/6cc77b32d61d11e28ab422000aa80430_5.jpg",
      "width": 150,
      "height": 150
    },
    "standard_resolution": {
      "url": "http://distilleryimage1.s3.amazonaws.com/6cc77b32d61d11e28ab422000aa80430_7.jpg",
      "width": 612,
      "height": 612
    }
  },
  "users_in_photo": [],
  "caption": {
    "created_time": "1371343377",
    "text": "Thanks @emilyangulo for the Oregon gear!! Ready for next season!! Love us @simplyme53 ❤ #GoDucks #oddcouple #denverbound",
    "from": {
      "username": "xalisurf1",
      "profile_picture": "http://images.ak.instagram.com/profiles/profile_294333021_75sq_1370997451.jpg",
      "id": "294333021",
      "full_name": "Alex Angulo"
    },
    "id": "479185443320969382"
  },
  "type": "image",
  "id": "479184488881928257_294333021",
  "user": {
    "username": "xalisurf1",
    "website": "",
    "profile_picture": "http://images.ak.instagram.com/profiles/profile_294333021_75sq_1370997451.jpg",
    "full_name": "Alex Angulo",
    "bio": "",
    "id": "294333021"
  }
}