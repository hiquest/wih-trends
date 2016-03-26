#
# Script that grabs data from HN.
#

# Dependencies
req = require "request"
async = require('async')
_ = require('underscore')
striptags = require('striptags')

# Configuration
DATA_LINKS = require './config/sources.json'
SLICES     = require './config/slices.json'

countOccurrence = (wrds, patterns) ->
  _.countBy(wrds, (w) ->
    _.some patterns, (p) ->
      w.toLowerCase() == p.toLowerCase()
  )['true']

# o.11415 rounds to 0.11
round = (num) ->
  Math.round(num * 100) / 100

splitWords = (body) ->
  striptags(body)
    .replace(/[\.,-\/#!$%\^&\*;:{}=\-_`~()]/g,"")
    .split(' ')

fetchPages = (cb) ->
  fns = DATA_LINKS.map (dl) ->
    (done) ->
      req { url: dl.url }, (error, response, body) ->
        throw "Could not download data from #{dl.url}" if error
        dl.body = splitWords(body)
        dl.count = (body.match(/athing/gi) || []).length
        done()
  async.series fns, cb

buildData = ->
  SLICES.map (sl) ->
    {
      slice: sl.slice,
      data: sl.items.map (itemOrItems) ->
        patterns = if _.isArray(itemOrItems) then itemOrItems else [itemOrItems]
        {
          item: patterns[0],
          data: DATA_LINKS.map (dl) ->
            {
              month: dl.month,
              count: round(countOccurrence(dl.body, patterns) / dl.count * 100)
            }
        }
    }

printOut = (data) ->
  console.log "window.hnData = #{JSON.stringify(data, null, 4)}"

# Start Here
fetchPages ->
  printOut(buildData())
