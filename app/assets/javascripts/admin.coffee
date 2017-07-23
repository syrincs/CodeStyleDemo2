$ ->
  return unless $('body').is('.admin')

  $("#admin_message_type").change  ->
    type = $(this).val()
    recipient_id = $("#admin_message_recipient_id").val()
    body = $("#admin_message_body").val()
    if body && body.length > 0
      window.location.search = "?recipient_id=#{recipient_id}&type=#{type}&body=#{body}"
    else
      window.location.search = "?recipient_id=#{recipient_id}&type=#{type}"

  $("#admin_message_body").keyup  charsCount = (e) ->
    return unless e.target
    helpBlock = $(e.target).siblings('.hint-block')
    text = helpBlock.text()
    current = $(e.target).val().length
    total = text.split('/')[1]
    helpBlock.text("#{current}/#{total}")

    if +current > +total
      $('input[type="submit"]').prop('disabled', true)
    else
      $('input[type="submit"]').prop('disabled', false)

  charsCount(target: $("#admin_message_body")[0])


  $('[data-toggle="tooltip"]').tooltip()
