#
# Script that grabs data from HN.
#

# Dependencies
req = require "request"
async = require('async')
_ = require('underscore')
cheerio = require('cheerio')

# Configuration
DATA_LINKS = require './config/sources.json'
SLICES     = require './config/slices.json'

countOccurrence = (items, patterns) ->
  _.countBy(items, ($i) ->
    text = $i.find('td.default .comment').text().toLowerCase()
    _.some patterns, (p) ->
      text.indexOf(p.toLowerCase()) > -1
  )['true']

# o.11415 rounds to 0.11
round = (num) ->
  Math.round(num * 100) / 100

topLevelThreads = (body) ->
  $ = cheerio.load(body)
  $('.athing td.ind img[width="0"]')
    .toArray()
    .map((x) -> $(x).parents('.athing'))

fetchPages = (cb) ->

  fns = DATA_LINKS.map (dl) ->
    (done) ->
      req { url: dl.url }, (error, response, body) ->
        if error
          throw "Could not download data from #{dl.url}"
        else
          dl.threads = topLevelThreads(body)
          done()

  async.series fns, cb

wrap = (i) ->
  if _.isArray(i)
    i
  else
    [i]

buildData = ->
  SLICES.map (sl) ->
    {
      slice: sl.slice,
      data: sl.items.map (itemOrItems) ->
        patterns = wrap(itemOrItems)
        {
          item: patterns[0],
          data: DATA_LINKS.map (dl) ->
            {
              month: dl.month,
              count: round(countOccurrence(dl.threads, patterns) / dl.threads.length * 100)
            }
        }
    }

printOut = (data) ->
  console.log "window.hnData = #{JSON.stringify(data, null, 4)}"

# Start Here
fetchPages ->
  printOut(buildData())
