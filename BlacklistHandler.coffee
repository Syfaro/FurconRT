fs = require 'fs'

class BlacklistHandler
    constructor: (@t) ->
        if fs.existsSync 'blacklist.json'
            @blacklist = JSON.parse fs.readFileSync 'blacklist.json', 'utf-8'
        else
            @blacklist = {}

        @r = /^@\w+\s+STOP\s*/i
        @u = /^@\w+\s+UNDO\s*/i

        @since = false

    inBlacklist: (name) ->
        name = name.toLowerCase()
        return if @blacklist[name]? then true else false

    addToBlacklist: (name) ->
        name = name.toLowerCase()
        if not @blacklist[name]?
            console.log "Added #{name} to blacklist"
            @blacklist[name] = true
            fs.writeFileSync 'blacklist.json', JSON.stringify @blacklist, null, '\t'

    removeFromBlacklist: (name) ->
        name = name.toLowerCase()
        if @blacklist[name]?
            console.log "Removed #{name} from blacklist"
            delete @blacklist[name]
            fs.writeFileSync 'blacklist.json', JSON.stringify @blacklist, null, '\t'

    updateBlacklist: ->
        @_pollTwitter(@t)

    _pollTwitter: (t) ->
        console.log 'Updating blacklist'

        _this = this
        t.get 'statuses/mentions_timeline', {
            since_id: _this.since
        }, (err, replies) ->
            if not replies?
                setTimeout ->
                    _this._pollTwitter t
                , 1000 * 60 * 2

                return

            first = true

            for reply in replies
                _this.since = if first then reply.id_str else _this.since

                if reply.text.match _this.r
                    _this.addToBlacklist reply.user.screen_name

                else if reply.text.match _this.u
                    _this.removeFromBlacklist reply.user.screen_name

            setTimeout ->
                _this._pollTwitter t
            , 1000 * 60 * 2

module.exports = BlacklistHandler
