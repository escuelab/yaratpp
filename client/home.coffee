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

### TWITTER ###
Twitter =
  initialized: false
  init: ->
    settings = Meteor.settings.public
    @cb = new Codebird
    @cb.setConsumerKey settings.TWITTER_KEY, settings.TWITTER_SECRET
    @cb.setToken settings.TWITTER_TOKEN, settings.TWITTER_TOKEN_SECRET

  tweet: ( tuit ) ->
    @cb.__call "statuses_homeTimeline", {}, (reply) ->
      console.log reply

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
  Twitter.init()
  reset 'firmante'

Template.home.tweet = ->
  return tuit()

Template.home.events
  "click #yo-firmo": ->
    tuit = tuit( get( 'firmante' ) || firmantePorDefecto )
    alert tuit
    Twitter.tweet tuit

  "change #firmante": (e) ->
    set 'firmante', $( e.currentTarget ).val()