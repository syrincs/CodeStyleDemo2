jQuery ($) ->
  $('.default .icon-check-circle', '.credit-cards-list, .bank-accounts-list').on 'click', ->
    icon = $(this)
    if $(this).closest('.default').hasClass('default-row')
      return false
    else
      $.ajax
        url: $(this).closest('.default').data('update-path')
        method: 'put'
        success: ->
          icon.closest('table').find('.default.default-row').removeClass('default-row')
          icon.closest('.default').addClass('default-row')
        error: ->
          console.log(arguments)

  $('.delete-row-icon', '.credit-cards-list, .bank-accounts-list').on
    'ajax:success': ->
      $(this).closest('tr').remove()
