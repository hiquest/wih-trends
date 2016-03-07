#
# Script that grabs data from HN.
#

# Dependencies
req = require "request"
async = require('async')
_ = require('underscore')

# Configuration
DATA_LINKS = [
  { month: "Aug'15", url: 'https://news.ycombinator.com/item?id=9996333' },
  { month: "Sep'15", url: 'https://news.ycombinator.com/item?id=10152809' },
  { month: "Oct'15", url: 'https://news.ycombinator.com/item?id=10311580' },
  { month: "Nov'15", url: 'https://news.ycombinator.com/item?id=10492086' },
  { month: "Dec'15", url: 'https://news.ycombinator.com/item?id=10655740' },
  { month: "Jan'16", url: 'https://news.ycombinator.com/item?id=10822019' },
  { month: "Feb'16", url: 'https://news.ycombinator.com/item?id=11012044' },
  { month: "Mar'16", url: 'https://news.ycombinator.com/item?id=11202954' }
]

SLICES = [
  {
    slice: 'langs',
    items: [
      'ruby', 'python', 'golang', 'java', 'elixir', 'php', 'javascript', 'objective-c', 'swift', 'erlang', 'haskell', 'rust', 'coffeescript', 'c\\+\\+', 'scala', 'closure'
    ]
  },
  {
    slice: 'jsFrameworks',
    items: ['react', 'angular', 'backbone', 'ember', 'knockout']
  },
  {
    slice: 'jsLangs',
    items: ['coffee', 'typescript', 'es6']
  },
  {
    slice: 'remoteVsOnsite',
    items: ['remote', 'onsite']
  }
]

# Algorithm
countOccurrence = (body, item) ->
  re = new RegExp(item, 'gi')
  (body.match(re) || []).length

cookData = (sl) ->
  sl.items.map (item) ->
    {
      item: item,
      data: DATA_LINKS.map (dl) ->
        {
          month: dl.month,
          count: countOccurrence(dl.body, item)
        }
    }

fetchPages = (cb) ->
  fns = DATA_LINKS.map (dl) ->
    (done) ->
      req { url: dl.url }, (error, response, body) ->
        throw 'Could not download data' if error
        dl.body = body
        done()
  async.series fns, cb

# Start Here
fetchPages ->
  out = SLICES.map (sl) ->
    {
      slice: sl.slice,
      data: cookData(sl)
    }
  console.log JSON.stringify(out, null, 4)
