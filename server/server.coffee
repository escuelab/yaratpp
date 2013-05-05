Tokens = new Meteor.Collection 'tokens'
Meteor.publish 'tokens', ->
  Tokens.find()

TwitterClient =
  init: ->
    settings = Meteor.settings.public
    # @cb = new Codebird
    # @cb.setConsumerKey settings.TWITTER_KEY, settings.TWITTER_SECRET
    # @cb.setToken settings.TWITTER_TOKEN, settings.TWITTER_TOKEN_SECRET
    # #token = Tokens.findOne()
    # #if token
    # #  @cb.setBearerToken token.it
    # #else
    # @authenticate()

    @T = new Twitter
      consumer_key:         settings.TWITTER_KEY
      consumer_secret:      settings.TWITTER_SECRET
      access_token:         settings.TWITTER_TOKEN
      access_token_secret:  settings.TWITTER_TOKEN_SECRET

    'success'

  # authorized: false
  # authenticate: ->
  #   console.log '--------- authenticate init'
  #   @cb.__call "oauth2_token", {}, (reply) ->
  #     console.log '--------- authenticate'
  #     console.log reply
  #     if reply.access_token
  #       Tokens.remove {}
  #       Tokens.insert
  #         it: reply.access_token
  #         createdAt: Date.now()

  tweet: ( tuit ) ->
    console.log '--------- intento de tuit '+tuit
    # status = "status=#{tuit}"
    # @cb.__call "statuses_update",
    #   {status}
    # , (reply) ->
    #   console.log '----------- tweet'
    #   console.log reply
    @T.post "statuses/update",
      status: tuit
    , (err, reply) ->
      console.log err
      console.log reply

Meteor.methods
  twitterInit: ->
    TwitterClient.init()

  twitterTweet: (tuit) ->
    TwitterClient.tweet tuit