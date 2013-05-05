### HELPERS ###
get = (key) ->
  return Session.get key
set = (key, val)->
  Session.set key, val
reset = (key)->
  Session.set key, null

registerHelper = (p1,p2) ->
  Handlebars.registerHelper p1, p2

registerHelper 'set', set
registerHelper 'get', get
registerHelper 'getStr', (key) ->
  JSON.stringify get( key )

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
  tweets[get 'curr-tweet']

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

  localStorage.clear()
  sample_url = Meteor.settings.public.GDOC_URL
  url_parameter = document.location.search.split(/\?url=/)[1]
  url = url_parameter or sample_url
  googleSpreadsheet = new GoogleSpreadsheet()
  googleSpreadsheet.url url
  googleSpreadsheet.load (result) ->
    set 'posibles-mencionados', result.data

Template.home.tweet = ->
  return tuit()

Template.home.opts = [1,2,3]

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

  "blur #mencionado": (e) ->
    set 'mencionado', $( e.currentTarget ).val()

  'click .opt': (e) ->
    val = parseInt( $(e.currentTarget).data('value') ) - 1
    set 'curr-tweet', val

Template.mencionado.rendered = ->
  posibles = get( 'posibles-mencionados' )
  $( "#mencionado" ).autocomplete
    source: posibles

Deps.autorun ->
  posibles = get( 'posibles-mencionados' )
  $( "#mencionado" ).autocomplete
    source: posibles