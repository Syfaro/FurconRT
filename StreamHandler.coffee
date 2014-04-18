TweetHandler = require './TweetHandler'

Array::remove = (value) ->
	idx = @.indexOf value
	if idx isnt -1
		return @.splice idx, 1

	return false

class StreamHandler
	constructor: (@T, @me, @keywords) ->
		@_startStream()

	getKeywords: ->
		return @keywords

	addKeyword: (keyword) ->
		console.log "Adding keyword: #{keyword}"

		if keyword instanceof Array
			@keywords = @keywords.concat keyword

		else
			@keywords.push keyword

		@_restartStream()


	removeKeyword: (keyword) ->
		console.log "Removing keyword: #{keyword}"

		if keyword instanceof Array
			for item in keyword
				@keywords.remove item

		else
			@keywords.remove keyword

		@_restartStream()


	_startStream: ->
		console.log 'Starting stream'

		@stream = @T.stream 'statuses/filter', {
			track: @keywords.join ','
		}

		_this = @
		@stream.on 'tweet', (tweet) ->
			_this._tweet tweet, _this.me, _this.T

	_stopStream: ->
		console.log 'Stopping stream'

		@stream.stop()

	_restartStream: ->
		console.log 'Restarting stream'

		@_stopStream()
		@_startStream()

		console.log 'Stream restarted'

	_tweet: (tweet, me, T) ->
		handler = new TweetHandler T, me, tweet

module.exports = StreamHandler
