const req = require("request")
const asy = require('async')
const _ = require('underscore')
const cheerio = require('cheerio')

const DATA_LINKS = require('./config/sources.json')
const SLICES     = require('./config/slices.json')

fetchPages(() => {
  printOut(buildData())
})

function countOccurrence(items, patterns) {
  return _.countBy(items, ($i) => {
    text = $i.find('td.default .comment').text().toLowerCase()
    return _.some(patterns, (p) => text.indexOf(p.toLowerCase()) > -1)
  })['true']
}

function topLevelThreads(body) {
  const $ = cheerio.load(body)
  return $('.athing td.ind img[width="0"]')
    .toArray()
    .map(x => $(x).parents('.athing'))
}

function fetchPages(cb) {
  const fns = DATA_LINKS.map((dl) =>
    (done) =>
      req({ url: dl.url }, (error, response, body) => {
        if (error) {
          throw "Could not download data from #{dl.url}"
        }

        dl.threads = topLevelThreads(body)
        done()
      }
    )
  )

  return asy.series(fns, cb)
}


function wrap(i) {
  return _.isArray(i) ? i : [i]
}

function buildData() {
  return SLICES.map((sl) =>
    ({
      slice: sl.slice,
      data: sl.items.map((itemOrItems) => {
        const patterns = wrap(itemOrItems)
        return {
          item: patterns[0],
          data: DATA_LINKS.map((dl) =>
            ({
              month: dl.month,
              count: round(countOccurrence(dl.threads, patterns) / dl.threads.length * 100)
            })
          )
        }
      })
    })
  )
}

function printOut(data) {
  console.log(`window.hnData = ${JSON.stringify(data, null, 4)}`)
}

// o.11415 rounds to 0.11
function round(num) {
  return Math.round(num * 100) / 100
}
