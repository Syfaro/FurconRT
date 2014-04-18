fs = require 'fs'
Twit = require 'twit'
StreamHandler = require './StreamHandler'

process.stdin.resume()
process.stdin.setEncoding 'utf8'

config = JSON.parse fs.readFileSync 'config.json', 'utf-8'

addkeyword = /^add (.*)/i
removekeyword = /^remove (.*)/i
list = /^list/i;

addblacklist = /^blacklist (.*)/i
remblacklist = /^unblacklist (.*)/i

stream = false

updateConfig = ->
	serialized = JSON.stringify {
		keywords: stream.getKeywords()
		twit: config.twit
	}, null, '\t'

	fs.writeFileSync 'config.json', serialized


process.stdin.on 'data', (text) ->
	if text.match addkeyword
		keyword = addkeyword.exec(text)[1].split ','
		stream.addKeyword keyword
		updateConfig()

	else if text.match removekeyword
		keyword = removekeyword.exec(text)[1].split ','
		stream.removeKeyword keyword
		updateConfig()

	else if text.match list
		console.log "Keywords: #{stream.getKeywords()}"

	else if text.match addblacklist
		user = addblacklist.exec(text)[1]
		stream.getBlacklistHandler().addToBlacklist user

	else if text.match remblacklist
		user = remblacklist.exec(text)[1]
		stream.getBlacklistHandler().removeFromBlacklist user

T = new Twit config.twit

T.get 'account/verify_credentials', (err, me) ->
	if err
		throw err

	console.log "Starting stream under #{me.screen_name}!"
	stream = new StreamHandler T, me, config.keywords
