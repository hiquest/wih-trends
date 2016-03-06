prepare = (data) ->
  data.map (lang) ->
    {
      name: lang.item,
      data: lang.data.map (x) -> x.count
    }

$ ->
  $('#langs').highcharts {
    title: { text: 'Programming Languages' },
    xAxis: { categories: hnData[0].data[0].data.map (x) -> x.month },
    series: prepare(hnData[0].data)
  }

  $('#jsf').highcharts {
    title: { text: 'JavaScript Frameworks' },
    xAxis: { categories: hnData[0].data[0].data.map (x) -> x.month },
    series: prepare(hnData[1].data)
  }
