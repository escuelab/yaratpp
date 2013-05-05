require = Npm.require

// Returns true if this is a host that closes *before* it ends?!?!
OAuthUtils = {}
OAuthUtils.isAnEarlyCloseHost= function( hostName ) {
  return hostName && hostName.match(".*google(apis)?.com$")
}