# Description:
#   Send messages to users the next time they speak
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot ambush <user name> <message>
#
# Author:
#   jmoses

moment = require('moment')

appendAmbush = (data, toUser, fromUser, message, time) ->
  data[toUser] or= []

  data[toUser].push { fromUser: fromUser, message: message, createdAt: time }

module.exports = (robot) ->
  robot.brain.on 'loaded', ->
    robot.brain.data.ambushes ||= {}

  robot.respond /ambush (.*?) (.*)/i, (msg) ->
    users = robot.brain.usersForFuzzyName(msg.match[1].trim())
    fromUser = msg.message.user.name
    if users.length is 1
      toUser = users[0].name
      appendAmbush(robot.brain.data.ambushes, toUser, fromUser, "#{msg.match[2]}", moment(new Date()))
      msg.send "OK #{fromUser}, ambush prepared for #{toUser}! I'll let them know when I see them."
    else if users.length > 1
      msg.send "Too many users like that."
    else
      msg.send "#{msg.match[1]}? Never heard of 'em."

  robot.hear /./i, (msg) ->
    return unless robot.brain.data.ambushes?
    username = msg.message.user.name
    if (ambushes = robot.brain.data.ambushes[username])
      for ambush in ambushes
        msg.send "Hey #{username}, #{ambush.createdAt.fromNow()}, #{ambush.fromUser} said: #{ambush.message}"
      delete robot.brain.data.ambushes[username]
