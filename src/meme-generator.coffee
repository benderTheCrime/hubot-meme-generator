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
request = require 'request'
url = 'https://api.imgflip.com/caption_image'
memes = [
  {
    regex: /(memegen )?(.*)(SUCCESS|NAILED IT.*)/i
    generatorID: 61544
  }
  {
    regex: /(memegen )?(NOT SURE IF .*) (OR .*)/i
    generatorID: 61520
  }
  {
    regex: /(memegen )?(YO DAWG .*) (SO .*)/i
    generatorID: 101716
  }
  {
    regex: /(memegen )?(one does not simply) (.*)/i
    generatorID: 61579
  }
  {
    regex: /(memegen )?(AM I THE ONLY ONE AROUND HERE) (.*)/i
    generatorID: 259680
  }
]

module.exports = (robot) ->
  memeResponder(robot, meme) for meme in memes

  robot.respond /(memegen )?(IF .*), ((ARE|CAN|DO|DOES|HOW|IS|MAY|MIGHT|SHOULD|THEN|WHAT|WHEN|WHERE|WHICH|WHO|WHY|WILL|WON\'T|WOULD)[ \'N].*)/i, (msg) ->
    memeGenerator msg, 61516, msg.match[2], msg.match[3] + (if msg.match[3].search(/\?$/)==(-1) then '?' else ''), (img) ->
      msg.send img

memeResponder = (robot, meme) ->
  robot.respond meme.regex, (msg) ->
    memeGenerator msg, meme.generatorID, msg.match[2], msg.match[3], (img) ->
      msg.send img

memeGenerator = (msg, generatorID, text0, text1, cb) ->
  username = process.env.HUBOT_MEMEGEN_USERNAME
  password = process.env.HUBOT_MEMEGEN_PASSWORD
  imgFlipUrl = url + objectToQueryString
    template_id: generatorID
    username: username
    password: password
    text0: text0
    text1: text1

  request.get imgFlipUrl, (e, res, body) ->
    return if e

    jsonBody = JSON.parse(body)
    success = jsonBody?.success

    return unless success

    img = jsonBody.data?.url

    unless img
      msg.reply "Ugh, I got back weird results from imgflip.net. Expected an image URL, but couldn't find it in the result. Here's what I got:", inspect(jsonBody)
      return

    cb img

objectToQueryString = (obj) -> '?' + (
  "#{k}=#{encodeURIComponent(v)}&" for k, v of obj
).join ''