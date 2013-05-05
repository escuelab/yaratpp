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

### APP ###

tuit = (firmante, mencionado) ->
  firmante = Template.firmante() unless firmante
  mencionado = Template.mencionado() unless mencionado
  tweets = [
    "cc #{mencionado} --asdasdasdas-- #{firmante}"
    "cc #{mencionado} ++aaaaaaaaaa+++ #{firmante}"
    "cc #{mencionado} ***** #{firmante}"
  ]
  tweets[0]

firmantePorDefecto = 'un ciudadano'
registerHelper 'firmantePorDefecto', -> firmantePorDefecto

mencionadoPorDefecto = '@robotest2'
registerHelper 'mencionadoPorDefecto', -> mencionadoPorDefecto

Template.home.created = ->
  Meteor.call 'twitterInit', (err, result) ->
    console.log err if err
    console.log result
  reset 'firmante'
  reset 'mencionado'

Template.home.tweet = ->
  return tuit()

Template.home.events
  "click #yo-firmo": ->
    firmante = get( 'firmante' ) or firmantePorDefecto
    mencionado = get( 'mencionado' ) or mencionadoPorDefecto
    tuit = tuit firmante, mencionado
    alert tuit
    #Meteor.call 'twitterTweet', tuit

  "change #firmante": (e) ->
    set 'firmante', $( e.currentTarget ).val()

  "change #mencionado": (e) ->
    set 'mencionado', $( e.currentTarget ).val()