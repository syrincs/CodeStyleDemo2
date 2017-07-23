jQuery ($) ->
  $('.profile-bio--show-more').on 'click', ->
    $(this).parents('.profile-bio').addClass('open')

  $('.profile-bio--show-less').on 'click', ->
    $(this).parents('.profile-bio').removeClass('open')

