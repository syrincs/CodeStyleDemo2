jQuery ($) ->
  $body = $('body');
  $button = $body.find('.js-loader')
  $container = $body.find('.js-container')

  $button.on 'click', (e) ->
    e.preventDefault();
    toggleState()
    if canPaginate()
      loadHTML(getPage())

  toggleState = () ->
    $button.toggleClass('loading')

  canPaginate = () ->
    $container.data('paginate')

  getPage = () ->
    $container.data 'page'

  updatePagination = (pagination) ->
    if pagination
      page = $container.data('page')
      $container.data('page', page + 1)
      $button.attr('href', "#{location.pathname}?page=#{page + 1}")
    else
      $container.data('pagination', 'false')
      $button.addClass('stop-paginate')

  updateView = (html) ->
    $html = $(html)
    $container.append $html
    if $body.find('.js-galary').lightGallery
      $body.find('.js-galary').lightGallery
        mode: 'lg-slide'
        preload: 3
        cssEasing: 'cubic-bezier(0.25, 0, 0.25, 1)'

  loadHTML = (page) ->
    $.ajax(
      url: "#{location.pathname}?page=#{page}"
      dataType: 'json'
      success: ((response) ->
        updatePagination(response.paginate)
        updateView(response.view)
        toggleState()
      )
      error: ((error) ->
        toggleState()
      )
    )
