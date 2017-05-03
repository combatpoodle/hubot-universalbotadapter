restify = require 'restify'
builder = require 'botbuilder'
{ Adapter } = require 'hubot'

class UniversalBotAdapter extends Adapter
  constructor: (robot) ->
    super

    @robot = robot

    @server = restify.createServer()
    @robot.logger.info "Connector startup"

    server = @server

    @server.listen process.env.port || process.env.PORT || 3978, @listening

    @connector = new builder.ChatConnector {
      appId: process.env.MICROSOFT_APP_ID,
      appPassword: process.env.MICROSOFT_APP_PASSWORD
    }

    @bot = new builder.UniversalBot @connector
    @server.post '/api/messages', @connector.listen()

    @bot.dialog '/', @gotSession, @gotSessionResults

  gotSession: (sesh) =>
    console.log "sesh", sesh
    @session = sesh

  gotSessionResults: (sesh, results) =>
    @session = sesh
    console.log "results", results
    @robot.logger.info "results", results

    @robot.receive results.response.entity

  listening: () =>
    @robot.logger.info '%s listening to %s', @server.name, @server.url

  send: (envelope, strings...) =>
    for string in strings
      @robot.logger.info "sending", string
      @session.send string

  reply: (envelope, strings...) =>
    for string in strings
      @robot.logger.info "sending", string
      @session.send string

exports.UniversalBotAdapter = UniversalBotAdapter