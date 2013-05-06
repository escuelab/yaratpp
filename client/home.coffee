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

#Firmas = new Meteor.Collection 'firmas'
#Meteor.subscribe 'firmas', get( 'firmante' ) or firmantePorDefecto, get( 'mencionado' ) or mencionadoPorDefecto

### APP ###
tuit = (firmante, mencionado) ->
  firmante = Template.firmante() unless firmante
  mencionado = Template.mencionado() unless mencionado
  tweets = [
    "yo #{firmante} le pido a usted #{mencionado} que mi libertad de expresión no se negocie en secreto en el TPP. #yaratpp http://bit.ly/yaratpp"
    "Sr/Sra #{mencionado} le pedimos que establezca límites no negociables que garanticen nuestros derechos en el TPP #{firmante} http://bit.ly/yaratpp"
    "Sr/Sra #{mencionado} negociar el #TPP en secreto, desde ya, restringue nuestra libertad de expresión att #firmante #YaraTPPhttp://bit.ly/yaratpp"
  ]
  tweets[get 'curr-tweet']

firmantePorDefecto = 'un ciudadano'
registerHelper 'firmantePorDefecto', -> firmantePorDefecto

mencionadoPorDefecto = Meteor.settings.public.DEFAULT_MENCIONADO
registerHelper 'mencionadoPorDefecto', -> mencionadoPorDefecto

Template.home.created = ->
  set 'curr-tweet', 0

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

    Meteor.call 'twitterTweet', elTweet, firmante, mencionado, (err, result) ->
      alert err if err
      alert result if result

      # firma = Firmas.findOne
      #   firmante: firmante
      #   mencionado: mencionado

      # console.log firma

      # if firma?.url
      #   alert firma?.url

  'keypress #firmante': (e) ->
    elem = e.currentTarget
    if elem.value.length >= firmantePorDefecto.length or firmanteInputWidth(elem) < 240
      set 'width-firmante', firmanteInputWidth(elem)

  'blur #firmante': (e) ->
    elem = e.currentTarget
    if elem.value
      set 'width-firmante', firmanteInputWidth(elem)
    else
      set 'width-firmante', 240

  "change #firmante": (e) ->
    val = $( e.currentTarget ).val()
    set 'firmante', val if val

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
