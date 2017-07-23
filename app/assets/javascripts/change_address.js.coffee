$ ->
  $scope = $ '#js-change-address-target'
  form = '.js-change-address-form'
  container = '.js-container'
  $container = $(container)

  return unless $scope.length

  $scope.on 'ajax:error', form, (ev, response) ->
    jsonResponse = JSON.parse response.responseText
    errors = jsonResponse.errors
    $html = $(jsonResponse.html).find(container)
    $container.replaceWith($html)

  $scope.on 'keydown', 'input', (ev) ->
    $(ev.currentTarget).parent('.form-group').removeClass('has-error')
    console.log('input')

  $scope.on 'ajax:success', form, (ev, response) ->
    $address = $(response.html)
    $('address').replaceWith $address
    $('#js-change-address-target').modal('hide')