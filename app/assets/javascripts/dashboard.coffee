jQuery ($) ->
  $('.accept-offer').on
    'ajax:beforeSend': ->
      console.log arguments
    'ajax:success': (e, resp) ->
      window.location = resp.redirect
      console.log arguments
#      window.location =
    'ajax:error': ->
      console.log arguments
    'ajax:complete': ->
      console.log arguments

  $('.dashboard-shipping-addresses .address-tile .delete-icon').on
    'ajax:success': ->
      $(this).closest('.address-tile').parent().remove()
      if $('.address-tile').length == 0
        $('.no-shipping-addresses').removeClass 'hidden'

    'ajax:error': (event, jqXHR) ->
      if jqXHR.responseJSON
        alert(jqXHR.responseJSON.message)
      else
        alert('Shipping Address can\'t be deleted')

  $('.dashboard-shipping-addresses .address-tile .js-set-default').on
    'ajax:success': ->
      window.location.reload()


  $('.button-order-received').on
    'ajax:beforeSend': ->
      $(this).attr('disabled', true)
    'ajax:success': ->
      window.location.reload()
    'ajax:complete': ->
      $(this).removeAttr('disabled')

  $('form.edit_address, form.new_address, .dashboard-settings form.edit_user').on 'submit', ->
    $(':submit', this).attr('disabled', true).addClass('btn-spinner')


  $('.js-show-enter-tracking-section').click ->
    $('.js-buy-shipping-label-section').removeClass('hidden')


  if /addresses\/new/.test location.pathname
    navigator.geolocation.getCurrentPosition (position) ->
      url = "//maps.google.com/maps/api/geocode/json?latlng=#{position.coords.latitude},#{position.coords.longitude}&sensor=false"
      $.getJSON url, (json) ->
        return unless json.results && json.results.length > 0

        address = json.results[0].address_components
        setAddress = ->
          $('#address_address1').val "#{address[0]?.long_name} #{address[1]?.long_name}"
          $('#address_city').val address[3]?.long_name
          $('#address_state').val address[4]?.long_name
          $('#address_zip_code').val address[6]?.long_name

        $("<h4>Guessed? <strong>#{json.results[0].formatted_address}</strong></h4>").insertBefore($('#new_address'))
        $("<a class='btn btn-action'>Fill form</a>").click(setAddress).insertBefore($('#new_address'))
