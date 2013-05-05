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

# Firmas = new Meteor.Collection 'firmas'
# Meteor.subscribe 'firmas'

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

    elTweet = tuit firmante, mencionado
    alert elTweet
    Meteor.call 'twitterTweet', elTweet, firmante, mencionado, (err, result) ->
      alert err if err
      alert result if result

  "change #firmante": (e) ->
    set 'firmante', $( e.currentTarget ).val()

  "change #mencionado": (e) ->
    set 'mencionado', $( e.currentTarget ).val()