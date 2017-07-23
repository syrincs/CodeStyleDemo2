jQuery ($) ->
  $('.search-categories-more').on 'click', (e) ->
    e.preventDefault()
    $('.categories-hidden').removeClass('hidden')
    $(this).hide()

  $('.result-sort-by select').on 'change', ->
    parsed = queryString.parse(location.search);
    parsed.sort = $(this).val()
    location.search = queryString.stringify(parsed);

  $('.popular-categories li.title > a').on 'click', ->
    $('.popular-categories li.title').removeClass('active')
    $(this).parents('li.title').toggleClass('active')
    return !$(this).siblings('ul').length
