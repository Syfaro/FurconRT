class TweetHandler
    constructor: (@t, @me, @tweet) ->
        if @goodTweet()
            @_retweet()

    goodTweet: ->
        if @_own()
            console.log 'Found own tweet'
            return

        if @_nsfw()
            console.log "Found potentially NSFW tweet #{@tweet.user.screen_name} - #{@tweet.id_str}"
            return

        if not @_containsMedia()
            console.log "Found tweet without media #{@tweet.user.screen_name} - #{@tweet.id_str}"
            return

        console.log "Found valid tweet #{@tweet.user.screen_name} - #{@tweet.id_str}"

        @_retweet()

    _own: ->
        if @tweet.user.screen_name == @me.screen_name
            return true

        return false

    _nsfw: ->
        if @tweet.user and @tweet.user.description and @tweet.user.description.toLowerCase().indexOf('nsfw') != -1
            if @tweet.text and @tweet.text.toLowerCase().indexOf('sfw') == -1
                return true

        return false

    _containsMedia: ->
        if @tweet.entities and @tweet.entities.media and @tweet.entities.media[0]
            return true

        return false

    _retweet: ->
        @t.post 'statuses/retweet/:id', {
            id: @tweet.id_str
        }, (err, reply) ->

module.exports = TweetHandler
