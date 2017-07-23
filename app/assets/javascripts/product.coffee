jQuery ($) ->
  productSlug = location.pathname.replace('/products/','')

  newCardForm = $('.product-form-new-card-details').remove().html();

  $('.cards-tooltip .add-new').on 'click', (e) ->
    e.preventDefault()
    $('.product-form-card-details').html(newCardForm);

  handleCCForm = (form) ->
    $form = $(form)
    $form.find(':submit').attr('disabled', true).addClass('btn-spinner')

    if $form.find('#credit_card_id').val() || $form.find('#cc-number').length == 0
      $form.get(0).submit();
      return true
    else
      createCreditCard($form)
      return false

  createCreditCard = ($form) ->
    stripeResponseHandler = (status, response) ->
      if (response.error)
        $form.find('#cc-security').parent().addClass('has-error').append("<label class='error'>#{response.error.message}</label>");
        $form.find(':submit').prop('disabled', false).removeClass('btn-spinner');
      else
        $form.find('#cc-number').val('')
        $form.append($('<input type="hidden" name="credit_card[stripe_token]" />').val(response.id));
        $form.append($('<input type="hidden" name="credit_card[brand]" />').val(response.card.brand));
        $form.append($('<input type="hidden" name="credit_card[display_number]" />').val("XXXX-XXXX-XXXX-#{response.card.last4}"));
        $form.get(0).submit();

    Stripe.card.createToken({
      name: $form.find('#cc-name').val(),
      number: $form.find('#cc-number').val(),
      cvc: $form.find('#cc-security').val(),
      exp_month: $form.find('#cc-expiration-month').val(),
      exp_year: $form.find('#cc-expiration-year').val()
    }, stripeResponseHandler);

  options = (additional={}) ->
    default_options =
      rules:
        'credit_card[verification_value]':
          required: true
          minlength: 3
        'credit_card[number]':
          required: true
        'credit_card[name]':
          required: true

      highlight: (element, errorClass, validClass) ->
        $(element).parent().addClass('has-error').removeClass(validClass)

      unhighlight: (element, errorClass, validClass) ->
        $(element).parent().removeClass('has-error').addClass(validClass)

      errorPlacement: (error, element) ->
        element.parent().append(error)

      submitHandler: (form) ->
        return handleCCForm(form)

    $.extend default_options, additional

  $('#new_credit_card').validate options()

  $('#new_offer').validate options
    submitHandler: (form) ->
      Intercom('trackEvent', 'submitted-offer', product: productSlug) if window.Intercom
      mixpanel.track("Product submit offer") if window.mixpanel
      return handleCCForm(form)

  $('#new_order').validate options()
  $('.bids-checkout-form').validate options()

  $('.bids-checkout-form .cards-tooltip li').on 'click', ->
    $('#credit_card_id').val($(this).data('id'))
    $('.bids-checkout-form').find('.product-form-card-exp p').text($(this).data('expiration_date'))
    $('.bids-checkout-form').find('.product-form-card-number').html($(this).html())

  $('.product-actions .button-buy-now').on 'click', (e) ->
    e.preventDefault()

    $('.checkout-form').toggle()
    $('.make-offer-form').hide()
    $('.button-make-offer').removeClass('active')
    $(this).toggleClass('active')

    # set click target for afer login
    $("#modal-login-form").data("click-after-login", ".button-buy-now");

    Intercom 'trackEvent', 'started-buy',
      product: productSlug

    top = $('.product-form.checkout-form').offset().top - $('header.main-header').height()
    if top > $(window).scrollTop()
      $('body').animate({scrollTop: top}, 400)


  $('.product-actions .button-make-offer').on 'click', (e) ->
    e.preventDefault()

    $('.checkout-form').hide()
    $('.make-offer-form').toggle()
    $('.button-buy-now').removeClass('active')
    $(this).toggleClass('active')
    $('.make-offer-form').find('.offer_amount input').focus()

    # set click target for afer login
    $("#modal-login-form").data("click-after-login", ".button-make-offer");

    top = $('.product-form.make-offer-form').offset().top - $('header.main-header').height()
    if top > $(window).scrollTop()
      $('body').animate({scrollTop: top}, 400)

    Intercom 'trackEvent', 'started-offer',
      product: productSlug

    dataLayer.push
      event: 'VirtualPageview'
      virtualPageURL: "/make_offer/funnel/step1/#{productSlug}"
      virtualPageTitle: 'virturl: Make offer – Step 1'

  if /buy-now/.test(window.location.href)
    $('.product-actions .button-buy-now').trigger('click')

  else if /make-offer/.test(window.location.href)
    $('.product-actions .button-make-offer').trigger('click')


  $firstThumb = $('.product-images-thumb').first().addClass('active')

  $('#zoom-img').attr
    'src': $firstThumb.data('image')
    'data-zoom-image': $firstThumb.data('zoom-image')

  if isTouchDevice()
    $('#zoom-img').click ->
      current = $(@src.split('/')).last()[0]
      images = $('.product-images-thumb')
      found = images.filter (index, a) ->
        new RegExp(current).test(a.dataset.image)
      currentIndex = images.index(found[0])
      nextImage = if images[currentIndex + 1]
        $(images[currentIndex + 1])
      else
        $(images[0])

      @src = nextImage.data('image')

    $('#thumb-gallery a').on 'click', ->
      $('#zoom-img').prop('src', $(this).data('image'))
      return false

  else
    $('#zoom-img').elevateZoom
      gallery: 'thumb-gallery'
      galleryActiveClass: 'active'
      imageCrossfade: true
      zoomWindowPosition: 'zoom-window'
      zoomWindowHeight: 460
      zoomWindowWidth: 656
      zoomWindowFadeIn: 200
      lensFadeIn: 200
      borderSize: 1
      borderColour: '#e6e6e6'
      easing: true
      easingDuration: 200
      responsive: true
      scrollZoom: true
      containLensZoom: true
      cursor: 'pointer'
      lensSize: 400

    $('#zoom-img').click ->
      current = $(@src.split('/')).last()[0]
      images = $('.product-images-thumb')
      found = images.filter (index, a) ->
        new RegExp(current).test(a.dataset.image)
      currentIndex = images.index(found[0])
      nextImage = if images[currentIndex + 1]
        $(images[currentIndex + 1])
      else
        $(images[0])

      elevateZoom = $(this).data('elevateZoom')
      elevateZoom.swaptheimage(nextImage.data('image'), nextImage.data('zoomImage'))

  $('#new_order', '.product-form').on 'submit', ->
    Intercom 'trackEvent', 'submitted-buy',
      product: productSlug
    mixpanel.track("Product submit buy");
    $(':submit', this).attr('disabled', true).addClass('btn-spinner')

  popoverOptions =
    html: true
    content: () ->
      $shareContent = $(this).siblings('.popover-content')
      return $shareContent.html()
    placement: () ->
      return if $(window).width() > 767 then 'left' else 'bottom'


  $popover = $('[data-toggle="popover"]');
  $popover.popover(popoverOptions);

  $popover.on 'shown.bs.popover', () ->
    $('.prettySocial').prettySocial()
    $('.popover .popover-content .watch-form').validate
      rules:
        phone_number:
          required: true
          phoneUS: true

      errorClass: 'help-block'
      errorElement: 'span'

      highlight: (element, errorClass, validClass) ->
        $(element).parent().addClass('has-error').removeClass(validClass)

      unhighlight: (element, errorClass, validClass) ->
        $(element).parent().removeClass('has-error').addClass(validClass)

      errorPlacement: (error, element) ->
        element.parent().append(error)

      submitHandler: (form) ->

        form.submit()


  $('.new_question').validate
    rules:
      'question[title]':
        required: true
      'question[description]':
        required: true
    errorClass: 'help-block'
    errorElement: 'span'

    highlight: (element, errorClass, validClass) ->
      $(element).parent().addClass('has-error').removeClass(validClass)

    unhighlight: (element, errorClass, validClass) ->
      $(element).parent().removeClass('has-error').addClass(validClass)

    errorPlacement: (error, element) ->
      element.parent().append(error)

    submitHandler: (form) ->
      $('.new_question :submit').attr('disabled', true).addClass('btn-spinner')
      form.submit()

  $('#offer_amount').on 'change keyup', ->
    amount = +this.value - 2
    if amount > 0
      $('.bid_amount_info').html("You pay <b>$2</b> now to confirm your offer. If the seller accepts your offer you will pay the remaining <b>$#{amount}</b>.")
      $('.bid_amount_info_short').html("If the seller accepts your offer you will pay <b>$#{this.value}</b>.")
    else
      $('.bid_amount_info_short').html("")
      $('.bid_amount_info').html("")

  $('#offer_amount').on 'change', ->
    $('.bid_amount_info_short, .bid_amount_info').clearQueue().queue (next) ->
      $(this).addClass("on"); next();
    .delay(800).queue (next) ->
      $(this).removeClass("on"); next();


  $.validator.addMethod "eitherEmailPhone", (value, element) ->
    return $.validator.methods['phoneUS'].call(this, value, element) || $.validator.methods['email'].call(this, value, element)
  , "Please enter either phone or e-mail"

  $('#help-me-to-sell form').validate
    rules:
      'contact[phone_number]':
        required: true
        eitherEmailPhone: true
      'product_description':
        required: true

    highlight: (element, errorClass, validClass) ->
      $(element).parent().addClass('has-error').removeClass(validClass)

    unhighlight: (element, errorClass, validClass) ->
      $(element).parent().removeClass('has-error').addClass(validClass)

    errorPlacement: (error, element) ->
      element.parent().append(error)

    submitHandler: (form) ->
      form.submit()
