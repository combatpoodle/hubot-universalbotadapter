{ UniversalBotAdapter } = require './src/universalbotadapter'

exports.use = (robot) ->
  new UniversalBotAdapter robot
