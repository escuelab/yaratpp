Firmas = new Meteor.Collection 'firmas'
Firmas.allow
  insert: -> false
  update: -> false
  remove: -> false

Meteor.publish 'firmas', ->
  Firmas.find()

TwitterClient =
  init: ->
    settings = Meteor.settings
    @T = new Twitter
      consumer_key:         settings.TWITTER_KEY
      consumer_secret:      settings.TWITTER_SECRET
      access_token:         settings.TWITTER_TOKEN
      access_token_secret:  settings.TWITTER_TOKEN_SECRET
    'success'

  tweet: ( tuit, firmante, mencionado ) ->
    @T.post "statuses/update",
      status: tuit
    , (err, reply) ->
      console.log err if err

      url = "https://twitter.com/#{Meteor.settings.TWITTER_USER}/status/#{reply.id_str}"

      Fiber = Npm.require 'fibers'
      Fiber( ->
        firma = Firmas.findOne
          firmante: firmante
          mencionado: mencionado

        Firmas.update firma._id, { $set:{ url:url } }
      ).run()

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
      throw new Meteor.Error "Ya has twitteado a ese funcionario tu opinión"
    else
      Firmas.insert
        firmante: firmante
        mencionado: mencionado

      TwitterClient.tweet tuit, firmante, mencionado
      return "Tweet enviado. Sigue a @#{Meteor.settings.TWITTER_USER}"