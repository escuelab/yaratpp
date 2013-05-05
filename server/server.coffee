Firmas = new Meteor.Collection 'firmas'
# Meteor.publish 'firmas', ->
#   Firmas.find()

TwitterClient =
  init: ->
    settings = Meteor.settings
    @T = new Twitter
      consumer_key:         settings.TWITTER_KEY
      consumer_secret:      settings.TWITTER_SECRET
      access_token:         settings.TWITTER_TOKEN
      access_token_secret:  settings.TWITTER_TOKEN_SECRET
    'success'

  tweet: ( tuit ) ->
    @T.post "statuses/update",
      status: tuit
    , (err, reply) ->
      console.log err if err
      console.log reply

Meteor.methods
  twitterInit: ->
    TwitterClient.init()

  twitterTweet: (tuit, firmante, mencionado) ->
    if tuit.length > 140
      throw new Meteor.Error """
      El tweet formado tiene más de 140 caracteres
      """

    firmaAnterior = Firmas.findOne
      firmante: firmante
      mencionado: mencionado

    if firmaAnterior
      throw new Meteor.Error """Ya se ha enviado una denuncia a esa
      funcionario y para ese firmante"""
    else
      Firmas.insert
        firmante: firmante
        mencionado: mencionado

      return 'Firma registrada'
      #TwitterClient.tweet tuit