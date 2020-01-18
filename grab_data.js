const req = require("request")
const rp = require('request-promise-native');
const _ = require('underscore')
const cheerio = require('cheerio')
const fs = require('fs');

const DATA_LINKS = require('./config/sources.json')
const SLICES     = require('./config/slices.json')

const ITEMS_PER_GROUP = 1  // optimal for performance

main()

async function main() {
  console.log('Starting...')
  const groups = inGroupsOf(DATA_LINKS, ITEMS_PER_GROUP)
  const dlinks = []

  for (let i = 0; i < groups.length; i++) {
    const g = groups[i]
    const dls = await Promise.all(g.map(fetchPage))
    dlinks.push(...dls)
  }

  console.log('Pages fetched...')

  const data = buildData(dlinks)
  fs.writeFileSync(
    'src/script/data.js',
    `window.hnData = ${JSON.stringify(data, null, 4)}`,
  );
}

async function fetchPage(dl) {
  try {
    let hasMore = true
    const threads = []
    let p = 0

    while (hasMore) {
      const url = `https://news.ycombinator.com/item?id=${dl.id}&p=${p++}`
      console.log(`>> ${dl.month} ${url}`)
      const body = await rp(url)
      const $ = cheerio.load(body)
      const th = $('.athing td.ind img[width="0"]')
        .toArray()
        .map(x => $(x).parents('.athing'))
      threads.push(...th)

      hasMore = $('a.morelink').length > 0
    }
    return { ...dl, threads }
  } catch(e) {
    console.log("Error origin: " + dl.month)
    console.log(e.message)
    throw e
  }
}

function countOccurrence(items, patterns) {
  return _.countBy(items, ($i) => {
    text = $i.find('td.default .comment').text().toLowerCase()
    return _.some(patterns, (p) => text.indexOf(p.toLowerCase()) > -1)
  })['true']
}

function wrap(i) {
  return _.isArray(i) ? i : [i]
}

function buildData(dlinks) {
  return SLICES.map((sl) =>
    ({
      slice: sl.slice,
      data: sl.items.map((itemOrItems) => {
        const patterns = wrap(itemOrItems)
        return {
          item: patterns[0],
          data: dlinks.map((dl) =>
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

// o.11415 rounds to 0.11
function round(num) {
  return Math.round(num * 100) / 100
}

function inGroupsOf(data, n) {
  var group = [];
  for (var i = 0, j = 0; i < data.length; i++) {
    if (i >= n && i % n === 0)
      j++;
    group[j] = group[j] || [];
    group[j].push(data[i])
  }
  return group;
}
