# Description:
#   朝会お知らせ
#
# Configuration:
#   ASAKAI_ROOM_NAME
#
# Dependencies:
#   "cron": "^1.3.0"
#   "moment": "^2.20.1"
#
# Commands:
#   hubot asakai_members ls - 朝会のメンバーを表示
#   hubot asakai_members add <name> - 朝会のメンバーを追加
#   hubot asakai_members rm <name> - 朝会のメンバーを削除
#   hubot asakai_members gacha - 朝会メンバーガチャ

moment = require 'moment'
{CronJob} = require 'cron'
moment.locale('ja')

# Sorry
Array.prototype.random = -> @[Math.floor(Math.random() * @length)]

gobi = [
  "ですよ！"
  "です。"
  "みたいです。"
  "みたいですよ〜。"
  "だ。"
  "だ！"
  "だよ。"
  "だね。"
  "っぽい。"
  "っぽい！"
  "ですわよ。"
  "ですな。"
  "でごわす。"
  "ですなぁ。"
]


emos = [
  "🤔"
  "😶"
  "😺"
  "😸"
  "😻"
  "😿"
  "😹"
  "😽"
  "😀"
]

redisKey = 'members'

module.exports = (robot) ->

  robot.respond /asakai_members ls/i, (res) ->
    members = robot.brain.get(redisKey)
    res.send JSON.stringify members

  robot.respond /asakai_members add (.+)/i, (res) ->
    name = res.match[1]
    members = robot.brain.get(redisKey) or []
    members.push {name}
    robot.brain.set(redisKey, members)
    res.send "added #{name}"
    res.send JSON.stringify members

  robot.respond /asakai_members rm (.+)/i, (res) ->
    name = res.match[1]
    members = robot.brain.get(redisKey) or []
    newMembers = members.filter (member)-> member.name isnt name
    robot.brain.set(redisKey, newMembers)
    res.send "removed #{name}"
    res.send JSON.stringify newMembers

  robot.respond /asakai_members gacha/i, (res) ->
    members = robot.brain.get(redisKey) or []
    res.send members.random()?.name

  #robot.messageRoom = (_, m)-> console.log m
  new CronJob '0 30 12 * * 1-5', ->
  #new CronJob '30 * * * * 1-5', ->
    robot.messageRoom process.env.ASAKAI_ROOM_NAME, """
    *---------- #{moment().format('M月D日(dddd)')} ----------*
    @channel :cat: 日報を作成しましょう :cat:
    ```
    *やったこと*
    - done
    →  ％くらい

    *やること*
    - doing

    *困ってること*
    - とくになし

    *頭の中*
    - #{emos.random()}

    ```
    """
  , null, true

  new CronJob '0 15 14 * * 1-5', ->
  #new CronJob '0 * * * * 1-5', ->
    members = robot.brain.get(redisKey) or []
    robot.messageRoom process.env.ASAKAI_ROOM_NAME, "@channel 日次会の時間#{gobi.random()} 今日の司会は @#{members.random()?.name} お願いします！"
  , null, true
