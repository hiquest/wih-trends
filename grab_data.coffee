#
# Script that grabs data from HN.
#

# Dependencies
req = require "request"
async = require('async')
_ = require('underscore')
striptags = require('striptags')

# Configuration
DATA_LINKS = [
  { month: "Jun'15", url: 'https://news.ycombinator.com/item?id=9639001' },
  { month: "Jul'15", url: 'https://news.ycombinator.com/item?id=9812245' },
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
      'ruby',
      'python',
      'golang',
      'java',
      'elixir',
      'php',
      'javascript',
      'objective-c',
      'swift',
      'erlang',
      'haskell',
      'rust',
      'coffeescript',
      'c++',
      'scala',
      'closure',
      'c#'
    ]
  },
  {
    slice: 'jsFrameworks',
    items: [
      ['ReactJS', 'react'],
      ['AngularJS', 'angular'],
      'backbone',
      'ember'
    ]
  },
  {
    slice: 'jsLangs',
    items: [
      ['CoffeeScript', 'Coffee'],
      'TypeScript',
      ['EcmaScript2016', 'es6', 'es2015']
    ]
  },
  {
    slice: 'remoteVsOnsite',
    items: ['remote', 'onsite']
  },
  {
    slice: 'mobile',
    items: ['ios', 'android']
  },
  {
    slice: 'Databases',
    items: [
      ['PostgreSQL', 'postgres'],
      'MySql',
      'sql server',
      'Oracle',
      ['MongoDB', 'mongo'],
      'redis',
      'cassandra']
  },
  {
    slice: 'Professions',
    items: [
      'Software Engineer',
      'Software Developer',
      'Full-stack',
      'Data Scien',
      'Data Engineer',
      'Devops'
    ]
  }
]

# Algorithm
countOccurrence = (wrds, patterns) ->
  _.countBy(wrds, (w) ->
    _.some patterns, (p) ->
      w.toLowerCase() == p.toLowerCase()
  )['true']

# o.11415 rounds to 0.11
round = (num) ->
  Math.round(num * 100) / 100

fetchPages = (cb) ->
  fns = DATA_LINKS.map (dl) ->
    (done) ->
      req { url: dl.url }, (error, response, body) ->
        throw "Could not download data from #{dl.url}" if error
        dl.body = striptags(body)
          .replace(/[\.,-\/#!$%\^&\*;:{}=\-_`~()]/g,"")
          .split(' ')
        dl.count = (body.match(/athing/gi) || []).length
        done()
  async.series fns, cb

# Start Here
fetchPages ->
  out = SLICES.map (sl) ->
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

  console.log JSON.stringify(out, null, 4)
