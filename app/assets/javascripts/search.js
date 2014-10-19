  // Helper
  Number.prototype.number_with_delimiter = function(delimiter) {
    var number = this + '', delimiter = delimiter || ',';
    var split = number.split('.');
    split[0] = split[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1' + delimiter);
    return split.join('.');
  };
  
  // faceting global variables
  var refinements = {};
  function toggleRefinement(facet, value) {
    var refine = facet + ':' + value;
    refinements[refine] = !refinements[refine];
    search();
  }
  


  // strip HTML tags + keep <em>, <p>, <b>, <i>, <u>, <strong>
  function stripTags(v) {
    return $('<div />').text(v).html().replace(/&lt;(\/)?(em|p|b|i|u|strong)&gt;/g, '<$1$2>');
  }
  
  // function called on each keystroke
  function searchCallback(success, content) {
    if (content.query != $("#inputfield input").val()) {
      // this results is out-dated, do not consider it
      return;
    }
  
    if (content.hits.length == 0 || content.query.trim() === '') {
      // no results or empty query
      $('#stats').empty();
      $('#facets').empty();
      $('#hits').empty();
      return;
    }
  
    var res = '';
    for (var i = 0; i < content.hits.length; ++i) {
      var hit = content.hits[i];
      console.log(hit)
      // render the hit
      res += '<div class="hit panel panel-default col-md-5">';
      // hit subtitle (date)
      if ('date' !== '') {
        var v = hit._highlightResult['date'] ?
          hit._highlightResult['date'].value :
          hit['date'];
        if (v && v.trim() !== '') {
          res += '<div class="panel-heading"><span class="panel-title date">Game Date:  ' + v + ' </span></div>';
        }
      }      
      /// hit title (home_team)
      if ('home_team' !== '') {
        var v = hit._highlightResult['home_team'] ?
          hit._highlightResult['home_team'].value :
          hit['home_team'];
        res += '<div class="home"><span class="h5">Home: ';
        if ('' !== '') { // url attribute
          res += '<a href="' + stripTags(hit['']) + '">' + v + '</a>';
        } else {
          res += v;
        }
        res += '-</span> ';
      }
      /// hit title (home_score)
      if ('home_score' !== '') {
        var v = hit._highlightResult['home_score'] ?
          hit._highlightResult['home_score'].value :
          hit['home_score'];
        res += '<span class="h5">';
        if ('' !== '') { // url attribute
          res += '<a href="' + stripTags(hit['']) + '">' + v + '</a>';
        } else {
          res += v;
        }
        res += '</span></div>';
      }
      /// hit title (away_team)
      if ('away_team' !== '') {
        var v = hit._highlightResult['away_team'] ?
          hit._highlightResult['away_team'].value :
          hit['away_team'];
        res += '<div class="away"><span class="h5">Away: ';
        if ('' !== '') { // url attribute
          res += '<a href="' + stripTags(hit['']) + '">' + v + '</a>';
        } else {
          res += v;
        }
        res += '-</span> ';
      }
      /// hit title (away_score)
      if ('away_score' !== '') {
        var v = hit._highlightResult['away_score'] ?
          hit._highlightResult['away_score'].value :
          hit['away_score'];
        res += '<span class="h5">';
        if ('' !== '') { // url attribute
          res += '<a href="' + stripTags(hit['']) + '">' + v + '</a>';
        } else {
          res += v;
        }
        res += '</span></div>';
      }
      /// hit title (id)
      if ('id' !== '') {
        var v = hit._highlightResult['id'] ?
          hit._highlightResult['id'].value :
          hit['id'];
        res += '<span class="last-item game-id">Id: ';
        if ('' !== '') { // url attribute
          res += '<a href="' + stripTags(hit['']) + '">' + v + '</a>';
        } else {
          res += v;
        }
        res += '</span> ';
      }
      // display all other attributes?
      if (false) {
        res += '<dl class="dl-horizontal">';
        for (var attr in hit) {
          if (attr !== 'objectID' && attr !== '_highlightResult' && attr != 'home_team' && attr != 'date' && attr != '') {
            var v;
            if (hit._highlightResult[attr]) {
              v = hit._highlightResult[attr].value;
            } else {
              v = hit[attr];
            }
            if (v && (typeof v !== 'string' || v.trim() !== '')) {
              res += "<dt>" + stripTags(attr) + ": </dt><dd>" + v + "</dd>";
            }
          }
        }
        res += '</dl>';
      }
      res += '<div class="clearfix"></div></div>';
    }
    $('#hits').html(res);
  
    if (content.facets && !$.isEmptyObject(content.facets)) {
      res = '<ul class="list-unstyled">'
      for (var facet in content.facets) {
        var facets = [];
        for (var f in content.facets[facet]) {
          facets.push([f, content.facets[facet][f]]);
        }
        facets.sort(function(a, b) { return a[1] < b[1] ? 1 : (a[1] > b[1] ? -1 : 0) });
        res += '<li class="m-b-large"><h3>' + facet + '</h3>' +
          '<ol class="list-unstyled m-l">' +
          $.map(facets, function(v) {
            return '<li class="' + stripTags(refinements[facet + ':' + v[0]] ? 'active' : '') + '"><a href="#" onclick="toggleRefinement(\'' + stripTags(facet) + '\', \'' + stripTags(v[0]) + '\'); return false;">' + stripTags(v[0]) + '</a> (' + v[1] + ')</li>';
          }).join('') +
          '</ol></li>';
      }
      res += '</ul>'
      $('#facets').html(res).css('float', 'left').css('width', '20%');
      $('#hits').css('float', 'right').css('width', '75%');
    }
  
    // stats
    $('#stats').html('<b>' + content.nbHits.number_with_delimiter() + '</b> result' + (content.nbHits > 1 ? 's' : '') + ', <b>' + content.processingTimeMS + '</b> ms')
  }
  
  
  $(document).ready(function() {
    var algolia = new AlgoliaSearch('PP9Q3BZYXI', '9f7829d832f710086e90718227471e6b');
    var index = algolia.initIndex('Game');
  
    window.search = function() {
      var facetFilters = [];
      for (var refine in refinements) {
        if (refinements[refine]) {
          facetFilters.push(refine);
        }
      }
      index.search($("#inputfield input").val(), searchCallback, {
        hitsPerPage: 10,
        facets: '*',
        maxValuesPerFacet: 10,
        facetFilters: facetFilters
      });
    }
  
    $("#inputfield input").keyup(function() {
      refinements = {};
      window.search();
    }).focus();
  
    if ($("#inputfield input").val() !== '') {
      window.search();
    }
  });