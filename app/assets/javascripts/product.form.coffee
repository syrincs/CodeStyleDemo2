jQuery ($) ->
  loadSubCategories = ->
    $('#product_car_model_id').html('')
    if @selectedOptions && @selectedOptions[0].value
      $.getJSON('/categories.json?parent=' + @selectedOptions[0].value).then (models) =>
        options = $.map models, (model) ->
          option = $('<option></option>').text(model.name).attr('value', model.id)
          option.attr('selected', 'selected') if $('#product_car_model_id').data('car-model-id') is model.id
          option

        options.unshift($('<option></option>').text('Select model').attr('value', ''))

        $('#product_car_model_id').append(options)

  toggleCarModelAndMake = ->
    return unless @selectedOptions

    if $(this.selectedOptions[0]).parent().attr('label') == 'Automotive & Parts'
      $('.car-fields').removeClass('hidden')
    else
      $('.car-fields').find('input, select').each ->
        $(this).val('')

      $('.car-fields').addClass('hidden')

  toggleCarModelAndMake.call($('#product_categorization_attributes_category_id')[0])
  loadSubCategories.call($('#product_car_make_id')[0])

  $('#product_categorization_attributes_category_id').on 'change', toggleCarModelAndMake

  $('#product_car_make_id').on 'change', loadSubCategories

  form = $('.edit-product-box form')

  return false if form.length == 0

  submit = $(':submit', form)

  form.on 'submit', ->
    submit.attr('disabled', true).addClass('btn-spinner')
