jQuery ($) ->

  $vid = $('.intro-video')
  $vid_xs = $('.intro-video_xs')

  closeVid = ->
    pauseVideo()
    pauseVideo()
    $vid.css
      'display': 'none'
      'opacity': 0
    $vid_xs.css
      'display': 'none'
      'opacity': 0

  pauseVideo = ->
    if iframe = $('.intro-video iframe').get(0)
      iframe.contentWindow.postMessage('{"event":"command","func":"pauseVideo","args":""}', '*')
    if iframe = $('.intro-video_xs iframe').get(0)
      iframe.contentWindow.postMessage('{"event":"command","func":"pauseVideo","args":""}', '*')

  playVideo = ->
    if iframe = $('.intro-video iframe').get(0)
      iframe.contentWindow.postMessage('{"event":"command","func":"playVideo","args":""}', '*')

  playVideoXs = ->
    if iframe = $('.intro-video_xs iframe').get(0)
      iframe.contentWindow.postMessage('{"event":"command","func":"playVideo","args":""}', '*')

  $('#watch-video, #watch-video-sm').on 'click', (e) ->
    e.preventDefault()
    $vid.css 'display', 'block'
    $vid[0].offsetWidth # force repaint
    $vid.css 'opacity', 1
    setTimeout(playVideo, 500)

  $('#watch-video-xs').on 'click', (e) ->
    e.preventDefault()
    $vid_xs.css 'display', 'block'
    $vid_xs[0].offsetWidth # force repaint
    $vid_xs.css 'opacity', 1
    setTimeout(playVideoXs, 500)

  $vid.find('.hide-intro-video').on 'click', closeVid
  $vid_xs.find('.hide-intro-video').on 'click', closeVid

  $vid.on 'click', (e) ->
    if ($vid.is(e.target))
      closeVid()

  $vid_xs.on 'click', (e) ->
    if ($vid_xs.is(e.target))
      closeVid()
