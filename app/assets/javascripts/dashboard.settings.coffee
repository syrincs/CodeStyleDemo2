jQuery ($) ->
  $('#update-password').on
    'ajax:before': ->
      $(':submit', this).attr('disabled', true).addClass('btn-spinner')
    'ajax:success': (e, resp) ->
      message = resp.message
      status = $(this).find('.actions .status')
      status.text(message).removeClass('error').addClass('success')
      this.reset()

    'ajax:error': (e, resp) ->
      try
        json = $.parseJSON resp.responseText

      if json
        message = json.message
      else
        message = "Password can't be changed"

      status = $(this).find('.actions .status')
      status.text(message).removeClass('success').addClass('error')

    'ajax:complete': ->
      $(':submit', this).removeAttr('disabled').removeClass('btn-spinner')
