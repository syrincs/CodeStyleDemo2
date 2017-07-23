(($, viewport) ->
  animationEnd = 'webkitAnimationEnd oanimationend oAnimationEnd msAnimationEnd animationend'

  $('a.how-banner-circle').on 'click', (e) ->
    offset = 200
    offset = 30 if viewport.is('xs')
    offset = 160 if viewport.is('sm')

    e.preventDefault()
    $('body').animate
      scrollTop: $($(this).attr('href')).offset().top - offset

  $('#an-stage-1, #an-stage-3').waypoint
    offset: 400
    handler: (dir) ->
      $el = $(this.element)

      if (dir == 'down'&& $el.hasClass('an-anim-init'))
        $el.removeClass('an-anim-init').addClass('an-anim-in')
      else if (dir == 'up')
        if ($el.is('#an-stage-1.an-anim-out'))
          $el.removeClass('an-anim-out').addClass('an-anim-init')
          $('#an-stage-2').removeClass('an-anim-in').addClass('an-anim-out').one animationEnd, ->
            $('#an-stage-2 .an-clock').removeClass('an-clock-out-freeze').insertAfter('#an-stage-1 .an-shadow').css top: '', left: ''
            $(this).removeClass('an-anim-out').addClass('an-anim-init')
        else if ($el.is('#an-stage-3.an-anim-in'))
          $el.removeClass('an-anim-in').addClass('an-anim-out').one animationEnd, ->
            $el.removeClass('an-anim-out').addClass('an-anim-init')


  $('#an-stage-1').waypoint
    handler: (dir) ->
      $el = $(this.element)
      $clock = $el.find('.an-clock')
      $stage2 = $('#an-stage-2')

      scale = 1

      if viewport.is('xs')
        scale = 3.33
      else if viewport.is('sm')
        scale = 2

      if (!$stage2.hasClass('an-anim-init'))
        return

      $el.removeClass('an-anim-in').addClass('an-anim-out')

      $clock.one animationEnd, ->
        pos = $clock.offset()
        posr = $stage2.offset()

        $stage2.removeClass('an-anim-init').addClass('an-anim-in')

        $clock.addClass('an-clock-out-freeze').insertAfter($stage2.find('.an-box-top')).css
          top: pos.top - posr.top + 'px'
          left: (pos.left - posr.left) * scale + 'px'

        $clock.animate({
          top: $stage2.find('.an-box-top').position().top - 15 + 'px'
        }, 500)

) jQuery, ResponsiveBootstrapToolkit

