### HELPERS ###
get = (key) ->
  return Session.get key
set = (key, val)->
  Session.set key, val
reset = (key)->
  Session.set key, null

registerHelper = (p1,p2) ->
  Handlebars.registerHelper p1, p2

registerHelper 'set', @set
registerHelper 'get', @get
registerHelper 'el', @get
registerHelper 'la', @get

Tokens = new Meteor.Collection 'tokens'
Meteor.subscribe 'tokens'

### APP ###

tuit = (firmante) ->
  firmante = Template.firmante() unless firmante
  tweets = [
    "----- #{firmante}"
    "+++++ #{firmante}"
    "***** #{firmante}"
  ]
  tweets[0]

firmantePorDefecto = 'un ciudadano'
registerHelper 'firmantePorDefecto', -> firmantePorDefecto

Template.home.created = ->
  Meteor.call 'twitterInit', (err, result) ->
    console.log err
    console.log result
  reset 'firmante'

Template.home.tweet = ->
  return tuit()

Template.home.events
  "click #yo-firmo": ->
    console.log get( 'firmante' )
    tuit = tuit( get( 'firmante' ) or firmantePorDefecto )
    Meteor.call 'twitterTweet', tuit, (err, result) ->
      console.log err
      console.log result

  "change #firmante": (e) ->
    set 'firmante', $( e.currentTarget ).val()