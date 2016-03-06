# Description:
#   Integrates with imgflip.net
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_MEMEGEN_USERNAME
#   HUBOT_MEMEGEN_PASSWORD
#
# Commands:
#   hubot memegen <text> (SUCCESS|NAILED IT) - Generates success kid with the top caption of <text>
#   hubot memegen Not sure if <text> or <text> - Generates Futurama Fry
#   hubot memegen Yo dawg <text> so <text> - Generates Yo Dawg
#   hubot memegen if <text>, <word that can start a question> <text>? - Generates Philosoraptor
#   hubot memegen one does not simply <text> - Lord of the Rings Boromir
#   hubot memegen AM I THE ONLY ONE AROUND HERE <text> - The Big Lebowski
# Author:
#   skalnik

inspect = require('util').inspect
request = require('request')

url = 'https://api.imgflip.com/caption_image'

module.exports = (robot) ->
  robot.brain.data.memes = [
    {
      regex: /(memegen )?(.*)(SUCCESS|NAILED IT.*)/i,
      generatorID: 61544
    }
    {
      regex: /(memegen )?(NOT SURE IF .*) (OR .*)/i,
      generatorID: 61520
    }
    {
      regex: /(memegen )?(YO DAWG .*) (SO .*)/i,
      generatorID: 101716
    }
    {
      regex: /(memegen )?(one does not simply) (.*)/i,
      generatorID: 61579
    }
    {
      regex: /(memegen )?(AM I THE ONLY ONE AROUND HERE) (.*)/i,
      generatorID: 259680
    }
  ]

  memeResponder(robot, meme) for meme in robot.brain.data.memes

  robot.respond /(memegen )?add meme \/(.+)\/i,(.+),(.+)/i, (msg) ->
    meme =
      regex: new RegExp(msg.match[2], "i")
      generatorID: parseInt(msg.match[3])
      imageID: parseInt(msg.match[4])

    robot.brain.data.memes.push meme
    memeResponder robot, meme

  robot.respond /(memegen )?(IF .*), ((ARE|CAN|DO|DOES|HOW|IS|MAY|MIGHT|SHOULD|THEN|WHAT|WHEN|WHERE|WHICH|WHO|WHY|WILL|WON\'T|WOULD)[ \'N].*)/i, (msg) ->
    memeGenerator msg, 17, 984, msg.match[2], msg.match[3] + (if msg.match[3].search(/\?$/)==(-1) then '?' else ''), (url) ->
      msg.send url

  robot.respond /(memegen )?((Oh|You) .*) ((Please|Tell) .*)/i, (msg) ->
    memeGenerator msg, 542616, 2729805, msg.match[2], msg.match[4], (url) ->
      msg.send url

memeResponder = (robot, meme) ->
  robot.respond meme.regex, (msg) ->
    memeGenerator msg, meme.generatorID, msg.match[2], msg.match[3], (url) ->
      msg.send url

memeGenerator = (msg, generatorID, text0, text1, callback) ->
  username = process.env.HUBOT_MEMEGEN_USERNAME
  password = process.env.HUBOT_MEMEGEN_PASSWORD

  request.get url + objectToQueryString({
    template_id: generatorID
    username: username
    password: password
    text0: text0
    text1: text1
  }), (e, res, body) ->
    if e
      console.log err
      return

    jsonBody = JSON.parse(body)
    success = jsonBody?.success

    unless success
      console.log jsonBody
      return

    img = jsonBody.data?.url

    unless img
      msg.reply "Ugh, I got back weird results from imgflip.net. Expected an image URL, but couldn't find it in the result. Here's what I got:", inspect(jsonBody)
      return

    msg.reply img

objectToQueryString = (obj) -> '?' + ("#{k}=#{v}&" for k, v of obj).join('')