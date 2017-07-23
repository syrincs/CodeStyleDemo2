jQuery ($) ->
  $body = $('body').addClass('js-bind')
  $window = $(window)

  touchMinWidth = 768
  desktopMinWidth = 992

  mobileCssClass = 'viewport-mobile'
  touchCssClass = 'viewport-touch'
  desktopCssClass = 'viewport-desktop'

  $window.on 'resize', () ->
    bindCssClass()

  bindCssClass = () ->
    viewPortWidth = $window.width()

    $body.removeClass("#{mobileCssClass} #{touchCssClass} #{desktopCssClass}")

    if viewPortWidth > desktopMinWidth
      $body.addClass desktopCssClass
    else if viewPortWidth > touchMinWidth
      $body.addClass touchCssClass
    else
      $body.addClass mobileCssClass

  bindCssClass()