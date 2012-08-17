cronJob = require('cron').CronJob
http = require 'http'
fs = require 'fs'
libxmljs = require 'libxmljs'

lastUpdate = 0

grabHubwayData = ->
    options =
        host: 'thehubway.com'
        path: '/data/stations/bikeStations.xml'

    http.get options, (res) ->
        resStr = ""
        res.setEncoding('utf8');

        res.on 'data', (chunk) ->
            resStr += chunk

        res.on 'error', ->
            console.log "Error fetching."

        res.on 'end', ->
            saveXmlData resStr

saveXmlData = (data) ->
    xmldoc = libxmljs.parseXmlString data
    thisUpdate = xmldoc.find('/stations')[0].attr('lastUpdate').value()

    if thisUpdate > lastUpdate
        fileName = "data/hubway_#{thisUpdate}.xml"
        fs.writeFile fileName, data, (err) ->
            unless err
                console.log "Saved data to #{fileName}"

        lastUpdate = thisUpdate
    else
        time = new Date().getTime()
        console.log "Not saving updates at #{time}."

mainLoop = new cronJob
    cronTime: '* * * * *'
    onTick: ->
        grabHubwayData()

    start: true