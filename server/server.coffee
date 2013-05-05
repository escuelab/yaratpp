TwitterClient =
  init: ->
    settings = Meteor.settings.public
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

  twitterTweet: (tuit) ->
    TwitterClient.tweet tuit