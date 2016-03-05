req = require "request"
async = require('async')
_ = require('underscore')

DATA_LINKS = [
  { month: 'December', url: 'https://news.ycombinator.com/item?id=10655740' },
  { month: 'January', url: 'https://news.ycombinator.com/item?id=10822019' },
  { month: 'February', url: 'https://news.ycombinator.com/item?id=11012044' },
  { month: 'March', url: 'https://news.ycombinator.com/item?id=11202954' }
]

SLICES = [
  {
    slice: 'langs',
    items: ['ruby', 'python', 'golang', 'java', 'elixir', 'javascript', 'objective-c', 'c\\+\\+', 'scala']
  },
  {
    slice: 'jsFrameworks',
    items: ['react', 'angular', 'backbone', 'vuejs', 'aurelia']
  }
]

monthData = (items, body) ->
  _.chain(items)
    .map (item) ->
      {
        item: item,
        count: countOccurrence(body, item)
      }
    .sortBy (x) -> - x.count
    .value()

countOccurrence = (body, item) ->
  re = new RegExp(item, 'gi')
  (body.match(re) || []).length

cookData = (sl) ->
  DATA_LINKS.map (dl) ->
    {
      month: dl.month,
      data: monthData(sl.items, dl.body)
    }

fns = DATA_LINKS.map (dl) ->
  (done) ->
    req { url: dl.url }, (error, response, body) ->
      if error
        throw 'Could not download data'
      dl.body = body
      done()

async.parallel fns, ->
  out = SLICES.map (sl) ->
    {
      slice: sl.slice,
      data: cookData(sl)
    }
  console.log JSON.stringify(out, null, 4)
