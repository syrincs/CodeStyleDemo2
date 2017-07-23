jQuery ($) ->
  $('.register-form').each ->
    form = $(this)
    submit = $(':submit', form)

    validator = form.validate
      rules:
        'user[first_name]':
          required: true
        'user[last_name]':
          required: true
        'user[email]':
          required: true
          email: true
        'user[password]':
          required: true
          minlength: 4
        terms:
          required: true
        'credit_card[number]':
          required: true
          creditcard: true
        'credit_card[name]':
          required: true
        'credit_card[verification_value]':
          required: true
          minlength: 3
          maxlength: 4
        expidation_date:
          required: true

      errorClass: 'help-block'
      errorElement: 'span'

      messages:
        'user[first_name]':
          required: "Enter your first name."
        'user[last_name]':
          required: "Enter your last name."
        'user[email]':
          required: "Enter your email address."
          email: "Enter a valid email address."
        'user[password]':
          required: 'Enter the password for your account.'
          minlength: 'Your password should be over 4-20 characters long.'
        'credit_card[number]':
          required: 'Enter valid card number.'
          creditcard: 'Enter valid card number.'
        'credit_card[name]':
          required: 'Enter the name displayed on the card.'
        'credit_card[verification_value]':
          required: 'Enter 3 digit security code displayed on the back of your card.'
        terms:
          required: 'Please agree with rules before proceed'

      groups:
        expidation_date: "date[month] date[year]"

      submitHandler: ->
        formLoading(true)
        sendForm()

      highlight: (element, errorClass, validClass) ->
        $(element).parent().addClass('has-error').removeClass(validClass);

      unhighlight: (element, errorClass, validClass) ->
        $(element).parent().removeClass('has-error').addClass(validClass);

      errorPlacement: (error, element) ->
        element.parent().append(error)


    sendForm = ->
      $.ajax
        url: form.attr('action'),
        type: "post",
        dataType: 'json',
        data: form.serializeArray(),
        success: (successObject) ->
          if successObject.destination_url
            window.location.replace successObject.destination_url
          else
            window.location.replace '/dashboard/addresses/new'
        error: (jqXHR) ->
          formLoading(false)
          if jqXHR.responseJSON
            errors = jqXHR.responseJSON.errors
            for key,val of errors
              args = {}
              args["user[#{key}]"] = val.join(', ')
              validator.showErrors args
          else
            alert('Error')

    formLoading = (active) ->
      if active
        submit.attr('disabled', true).addClass('btn-spinner')
      else
        submit.removeAttr('disabled').removeClass('btn-spinner')

  $('#restore-password').on
    'submit': ->
      $(this).find('.has-error').removeClass('has-error')

      if $('#password').val() == ''
        $('#password').parent().addClass('has-error')
        return false

      if $('#password_confirmation').val() == ''
        $('#password_confirmation').parent().addClass('has-error')
        return false

      if $('#password').val() != $('#password_confirmation').val()
        $('#password').parent().addClass('has-error')
        $('#password_confirmation').parent().addClass('has-error')
        return false


  $('.session-sign-in form').on 'submit', ->
    $(':submit', this).attr('disabled', true).addClass('btn-spinner')
