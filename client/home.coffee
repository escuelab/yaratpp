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
registerHelper 'get', (key) ->
  result = get key
  return result or ''
registerHelper 'getStr', (key) ->
  JSON.stringify get( key )

Firmas = new Meteor.Collection 'firmas'
Meteor.subscribe 'firmas'

### APP ###
tuit = (firmante, mencionado) ->
  firmante = Template.firmante() unless firmante
  mencionado = Template.mencionado() unless mencionado
  tweets = [
    "Sr/a #{mencionado}: Proteja mi libertad en el capítulo de propiedad intelectual del TPP. Atte. #{firmante} http://bit.ly/yaratpp #yaratpp"
    "Sr/a #{mencionado}: Garantice nuestros derechos en el TPP. Hay límites no negociables. Atte. #{firmante} http://bit.ly/yaratpp #esono"
    "Sr/a #{mencionado}: Negocien el TPP por-y-con nosotros, y no a nuestras espaldas. Atte. #{firmante} http://bit.ly/yaratpp #yaratpp"
  ]
  tweets[get 'curr-tweet']

firmantePorDefecto = 'un ciudadano'
registerHelper 'firmantePorDefecto', -> firmantePorDefecto

mencionadoPorDefecto = Meteor.settings.public.DEFAULT_MENCIONADO
registerHelper 'mencionadoPorDefecto', -> mencionadoPorDefecto

registerHelper 'linkear', (text) ->
  regexLink = /[-a-zA-Z0-9@:%_\+.~#?&\/=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&\/=]*)?/gi
  arr = text.match regexLink
  if arr
    for match in arr
      if startsWith match, 'http'
        text = text.replace match, "<a href='#{match}' target='_blank'>#{match}</a>"

  regexHashtag = /#[-a-zA-Z0-9]{1,50}\b/gi
  arr = text.match regexHashtag
  if arr
    for match in arr
      hashUrl = "https://twitter.com/search?q=#{match.replace '#', '%23'}&src=hash"
      text = text.replace match, "<a href='#{hashUrl}' target='_blank'>#{match}</a>"

  text

Template.home.created = ->
  set 'curr-tweet', 0

  Meteor.call 'twitterInit', (err, result) ->
    console.log err if err

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

Template.home.charCount = ->
  tuit1 = tuit(getFirmante(), getMencionado())
  tuit1.length

getFirmante = ->
  get( 'firmante' ) or firmantePorDefecto

getMencionado = ->
  get( 'mencionado' ) or mencionadoPorDefecto

Template.home.events
  "click #yo-firmo": ->
    firmante = getFirmante()
    mencionado = getMencionado()

    elTweet = tuit firmante, mencionado

    Meteor.call 'twitterTweet', elTweet, firmante, mencionado, (err, result) ->
      alert err if err
      #alert result if result

  'keypress #firmante': (e) ->
    elem = e.currentTarget
    val = $( elem ).val()
    set 'firmante', val
    if elem.value.length >= firmantePorDefecto.length or firmanteInputWidth(elem) < 240
      set 'width-firmante', firmanteInputWidth(elem)

  'blur #firmante': (e) ->
    elem = e.currentTarget
    val = $( elem ).val()
    set 'firmante', val
    if elem.value
      set 'width-firmante', firmanteInputWidth(elem)
    else
      set 'width-firmante', 240
    

  "blur #mencionado": (e) ->
    set 'mencionado', $( e.currentTarget ).val()

  'click .opt': (e) ->
    val = parseInt( $(e.currentTarget).data('value') ) - 1
    set 'curr-tweet', val

firmanteInputWidth = (elem) ->
  ((elem.value.length + 1) * 22)

setupAutocomplete = ->
  posibles = get( 'posibles-mencionados' )
  $( "#mencionado" ).autocomplete(
    source: posibles
    minLength: 0
  ).focus ->
    $(this).autocomplete 'search'

Template.mencionado.rendered = ->
  setupAutocomplete()

Deps.autorun ->
  setupAutocomplete()

Firmas.find().observe
  changed: (oldD, newD) ->
    if oldD.url and oldD.firmante is getFirmante() and oldD.mencionado is getMencionado()
      window.location = oldD.url