$(()=> {
  drawChart($('#programming-langs'), 'Programming Languages', hnData[0].data)
  drawChart($('#javascript-frameworks'), 'JavaScript Frameworks', hnData[1].data)
  drawChart($('#javascript-langs'), 'JavaScript Compiled Langs', hnData[2].data)
  drawChart($('#remote-vs-onsite'), 'Remote Vs. Onsite', hnData[3].data)
  drawChart($('#mobile'), 'Mobile', hnData[4].data)
  drawChart($('#databases'), 'Databases', hnData[5].data)
  drawChart($('#professions'), 'Professions', hnData[6].data)
  drawChart($('#cities'), 'Cities', hnData[7].data)
  drawChart($('#cloud'), 'Cloud', hnData[8].data)
  drawChart($('#web-frameworks'), 'Web Frameworks', hnData[9].data)
})

function drawChart($cont, title, data) {
  $cont.highcharts({
    title: { text: title },
    xAxis: { categories: hnData[0].data[0].data.map((x) => x.month) },
    yAxis: { title: { text: 'Mentions (%)' } },
    series: prepare(data)
  })
}

function prepare(data) {
  return data.map(lang => ({
    name: lang.item,
    data: lang.data.map(x => x.count)
  }))
}
