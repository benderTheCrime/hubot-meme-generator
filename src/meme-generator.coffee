# Description:
#   Integrates with memegenerator.net
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_MEMEGEN_USERNAME
#   HUBOT_MEMEGEN_PASSWORD
#   HUBOT_MEMEGEN_DIMENSIONS
#
# Commands:
##   hubot memegen Y U NO <text>  - Generates the Y U NO GUY with the bottom caption of <text>
##   hubot memegen I don't always <something> but when i do <text> - Generates The Most Interesting man in the World
##   hubot memegen <text> ORLY? - Generates the ORLY? owl with the top caption of <text>
#   hubot memegen <text> (SUCCESS|NAILED IT) - Generates success kid with the top caption of <text>
##   hubot memegen <text> ALL the <things> - Generates ALL THE THINGS
##   hubot memegen <text> TOO DAMN <high> - Generates THE RENT IS TOO DAMN HIGH guy
#   hubot memegen good news everyone! <news> - Generates Professor Farnsworth
##   hubot memegen khanify <text> - TEEEEEEEEEEEEEEEEEXT!
#   hubot memegen Not sure if <text> or <text> - Generates Futurama Fry
#   hubot memegen Yo dawg <text> so <text> - Generates Yo Dawg
##   hubot memegen ALL YOUR <text> ARE BELONG TO US - Generates Zero Wing with the caption of <text>
#   hubot memegen if <text>, <word that can start a question> <text>? - Generates Philosoraptor
##   hubot memegen <text> FUCK YOU - Angry Linus
##   hubot memegen (Oh|You) <text> (Please|Tell) <text> - Willy Wonka
#   hubot memegen <text> you're gonna have a bad time - Bad Time Ski Instructor
#   hubot memegen one does not simply <text> - Lord of the Rings Boromir
#   hubot memegen it looks like (you|you're) <text> - Generates Clippy
#   hubot memegen AM I THE ONLY ONE AROUND HERE <text> - The Big Lebowski
##   hubot memegen <text> NOT IMPRESSED - Generates McKayla Maroney
##   hubot memegen PREPARE YOURSELF <text> - Generates GoT
##   hubot memegen WHAT IF I TOLD YOU <text> - Generates Morpheus
##   hubot memegen <text> BETTER DRINK MY OWN PISS - Generates Bear Grylls
##   hubot memegen INTERNET KID <text>, <text> - Generates First-day-on-the-Internet Kid
# Author:
#   skalnik

inspect = require('util').inspect

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

memeGenerator = (msg, generatorID, imageID, text0, text1, callback) ->
  username = process.env.HUBOT_MEMEGEN_USERNAME
  password = process.env.HUBOT_MEMEGEN_PASSWORD

  msg.http('https://api.imgflip.com/caption_image')
    .query
      template_id: generatorID
      username: username
      password: password
      text0: text0,
      text1: text1
    .get() (err, res, body) ->
      return if err

      jsonBody = JSON.parse(body)
      success = jsonBody?.success

      return if not success

      img = jsonBody.data?.url

      unless img
        msg.reply "Ugh, I got back weird results from imgflip.net. Expected an image URL, but couldn't find it in the result. Here's what I got:", inspect(jsonBody)
        return

      callback img