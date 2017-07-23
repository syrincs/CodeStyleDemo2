jQuery ($) ->
  if $('.js-galary').lightGallery
    $('.js-galary').lightGallery
      mode: 'lg-slide'
      preload: 3
      cssEasing: 'cubic-bezier(0.25, 0, 0.25, 1)'


  $('.product-additional-info .nav-tabs a').on 'click', (e) ->
    e.preventDefault()
    $(this).tab('show')

  renderCreditCard = (parent, li) ->
    parent.find('.credit_card_id').val($(li).data('id'))
    parent.find('.product-form-card-number').html($(li).html())
    parent.find('.expiration-date p').text($(li).data('expiration_date'))

  $('.make-offer-form .cards-tooltip li').on 'click', ->
    renderCreditCard($('.make-offer-form'), this)

  $('.checkout-form .cards-tooltip li').on 'click', ->
    renderCreditCard($('.checkout-form'), this)

  $('.search-input').on
    focus: ->
      $(this).closest('form').addClass('focused')
    blur: ->
      $(this).closest('form').removeClass('focused')

  if isMobile()
    $('.js-slick-slider-showcase .slider-showcase-wrapper').slick
#      centerMode: true,
#      centerPadding: '60px',
      slidesToShow: 3,
      variableWidth: true
      responsive: [
        {
          breakpoint: 768,
          settings: {
            arrows: false,
#            centerMode: true,
#            centerPadding: '20px',
            slidesToShow: 3
          }
        },
        {
          breakpoint: 480,
          settings: {
            arrows: false,
#            centerMode: true,
#            centerPadding: '10px',
            slidesToShow: 2
          }
        }
      ]

  $('.js-slick-slider').slick
    mobileFirst: true,
    autoplay: true,
    autoplaySpeed: 8000,
    infinite: true,
    dots: true,
    arrows: false,
    pauseOnDotsHover: true,
    initialSlide: 0,
    responsive: [
      {
        breakpoint: 1024,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          infinite: true,
          dots: true
        }
      },
      {
        breakpoint: 600,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          infinite: true,
          dots: true
        }
      },
      {
        breakpoint: 480,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          infinite: true,
          dots: true
        }
      }
    ]


  $cover = $('.categories-list__cover').css
    height: $(document).height()

  $menu = $('.categories-list')

  getWidth = (menu) ->
    menu.outerWidth() + (menu.outerWidth(true) - menu.outerWidth()) / 2

  activateSubmenu = (row) ->
    $row = $(row)
    $submenu = $row.find('.categories-list__sub-categories')
    height = $menu.outerHeight()
    width = getWidth($menu)
    # Show the submenu
    $submenu.css
      display: 'block'
      top: 0
      left: width - 2
    $menu.addClass('active')
    # Keep the currently activated row's highlighted look
    $row.children('a').addClass 'active'
    return

  deactivateSubmenu = (row) ->
    $row = $(row)
    $submenu = $row.find('.categories-list__sub-categories')
    # Hide the submenu and remove the row's highlighted look
    $submenu.css 'display', 'none'
    $row.children('a').removeClass 'active'
    $menu.removeClass('active')
    return

  $('.categories.dropdown').on 'show.bs.dropdown', ->
    $cover.css('display', 'block').addClass('active')
    $('.zoomContainer').css(zIndex: 0)

  $('.categories.dropdown').on 'hide.bs.dropdown', ->
    $cover.removeClass('active').on('transitionend webkitTransitionEnd oTransitionEnd', -> $cover.css('display', 'none'))
    $('.zoomContainer').css(zIndex: 99)

  $menu.menuAim
    activate: activateSubmenu
    deactivate: deactivateSubmenu
    exitMenu: ->
      $menu.removeClass('active')

  # Bootstrap's dropdown menus immediately close on document click.
  # Don't let this event close the menu if a submenu is being clicked.
  # This event propagation control doesn't belong in the menu-aim plugin
  # itself because the plugin is agnostic to bootstrap.
  $('.categories-list__top-categories li').click (e) ->
    e.stopPropagation()
    return

  $(document).click ->
    # Simply hide the submenu on any click. Again, this is just a hacked
    # together menu/submenu structure to show the use of jQuery-menu-aim.
    $('.categories-list__sub-categories').css 'display', 'none'
    $menu.find('a.active').removeClass 'active'
    return

  $('.js-open-submenu').on 'click', ->
    $('.js-submenu').removeClass('active')
    $(this).next('.js-submenu').addClass('active')
    return false
