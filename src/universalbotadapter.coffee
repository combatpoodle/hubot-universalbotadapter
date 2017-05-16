restify = require 'restify'
builder = require 'botbuilder'
{ Adapter, TextMessage, User } = require 'hubot'

class UniversalBotAdapter extends Adapter
  constructor: (robot) ->
    super robot

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

    @bot.dialog '/', @gotSession

  gotSession: (session, args, next) =>
    user = new User(session.message.user.id, session.message.user)

    selfName = session.message.text.replace(/<at>(.*)<\/at>.*/, '$1')
    @robot.name = selfName

    messageText = session.message.text.replace(/<at>/i, '').replace(/<\/at>\W*/i, ' ')
    message = new TextMessage(user, messageText)

    @session = session
    @robot.receive message

  listening: () =>
    @robot.logger.info '%s listening to %s', @server.name, @server.url

  send: (envelope, strings...) =>
    console.log("send", envelope, strings)
    for string in strings
      @robot.logger.info "sending", string
      @session.send string

  reply: (envelope, strings...) =>
    console.log(envelope, strings)
    for string in strings
      @session.send string

exports.UniversalBotAdapter = UniversalBotAdapter