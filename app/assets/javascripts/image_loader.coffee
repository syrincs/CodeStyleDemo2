#= require jquery-fileupload/basic

$ ->
  $body = $('body');
  $file = $body.find('.js-image-loader > input[type=file]')
  $dropZone = $body.find('.js-image-loader')
  $form = $body.find('.js-store-product-form')
  $submit = $body.find('.js-submit-store-product')

  isFileSizeOk = (file) ->
    Rollbar.info("Product uploading: file size #{file.size}") if Rollbar?
    file.size < 15 * 1024 * 1024

  isFileDimensionMore1024 = (file, base64, callback) ->
    image = new Image()
    image.src = base64

    $(image).on 'load', ->
      if image.width >= 1024 or image.height >= 1024
        callback(base64)
      else
        Rollbar.error("#{file.name}: either image width or height must be more than 1024px. [#{image.width}x#{image.height}]") if Rollbar?
        alert("#{file.name}: either image width or height must be more than 1024px.");
        false

  $dropZone.fileupload
    drop: (e, data) ->
      $.each data.files, (index, file) ->
        console.log('Dropped file: ' + file.name)

    change: (e, data) ->
      $.each data.files, (index, file) ->
        console.log('Selected file: ' + file.name)

    add: (e, data) ->
      file = data.files[0]
      reader = new FileReader()
      reader.onload = (e) ->
        isFileDimensionMore1024 file, e.target.result, (base64) ->
          img_wrap = $('.images-list .img-blank').clone()
          img_wrap.removeClass('img-blank')
          img_wrap.find('img').css
            width: 100
            height: 100
            backgroundImage: "url(#{base64})"
            backgroundSize: 'cover'
            backgroundPosition: 'center center'
            backgroundRepeat: 'no-repeat'
          $('.images-list .previews').append(img_wrap)

          img_wrap.find('.js-photo').val(base64)


      if isFileSizeOk(file)
        reader.readAsDataURL(file, e.target.result)
      else
        alert('File size should be less than 15MB')
        return

  $('.images-list').on 'click', '.delete', (e) ->
    img = $(this).closest('.img')
    img.remove()

  convertFileToDataURL = (url, callback) ->
    xhr = new XMLHttpRequest
    xhr.responseType = 'blob'

    xhr.onload = ->
      reader = new FileReader

      reader.onloadend = ->
        callback reader.result
        return

      reader.readAsDataURL xhr.response
      return

    xhr.open 'GET', url
    xhr.send()
    return

  $('.previews .img').each (index, img) ->
    $img = $(img)
    convertFileToDataURL $img.find('img').attr('src'), (base64) ->
      $img.find('.js-photo').attr('value', base64)

  if previews = $('.images-list .previews')[0]
    Sortable.create previews,
      draggable: '.img'
      animation: 150
      ghostClass: "sortable-ghost"
      onUpdate: (event) ->
        $(event.from).find('.js-position_order').each (index, item) ->
          $(item).val(index)

  $submit.on 'click', (e) ->
    e.preventDefault();

    if $body.find('.previews > .img').length < 2
      $dropZone.addClass('error')
      return
    else
      $dropZone.removeClass('error')
      $form.submit()
