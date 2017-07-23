//= require jquery
//= require jquery_ujs
//= require sortable.min
//= require jquery.validate
//= require additional-methods
//= require jquery.elevatezoom
//= require jquery.waypoints.min
//= require bootstrap
//= require bootstrap-hover-dropdown
//= require bootstrap-toolkit.min
//= require query-string
//= require jquery.prettySocial
//= require slick-1.5.9/slick/slick.min.js
//= require jquery.countdown.min
//= require picturefill.min
//= require slideout.min
//= require jquery.menu-aim
//= require browser-update.min

//= require_self
//= require main
//= require devise
//= require how
//= require video
//= require dashboard
//= require dashboard.payment-details
//= require dashboard.settings
//= require product
//= require product.form
//= require sessions
//= require modal-login
//= require profile
//= require search
//= require loader
//= require image_loader
//= require admin
//= require change_address

function isTouchDevice() {
  return 'ontouchstart' in window || 'onmsgesturechange' in window;
}

function isMobile() {
    var iphone = /iPhone|iPod/i.test(navigator.platform);
    var other = /Android|webOS|iPhone|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

    if (iphone || other) {
        return true
    } else {
        if (window['matchMedia'] && typeof window['matchMedia'] == 'function') {
            var media = window.matchMedia("only screen and (max-width: 767px)");
            return media.matches;
        }
    }
}

$(function(){
    var $clock = $('.js-countdown');
    var time = new Date($('.js-countdown').attr('datetime'));
    if(time > new Date()) {
        $clock.countdown(time, function(event) {
            $(this).html(event.strftime('%D days %H:%M:%S'));
        }).on('finish.countdown', function(){
            $(this).html('Finished!')
        });
        $('.countdown').removeClass('hidden');
    }

    var $detail_clock = $('.js-countdown-detail');
    var detail_time = new Date($('.js-countdown-detail').attr('datetime'));
    if(detail_time > new Date()) {
        $detail_clock.countdown(detail_time, function(event) {
            var days = event.strftime('%D').split('');
            var hours = event.strftime('%H').split('');
            var minutes = event.strftime('%M').split('');
            var seconds = event.strftime('%S').split('');

            $(this).html(event.strftime(
                '<div class="countdown-value days">' +
                    '<span class="value-wrapper">' +
                        '<span class="value">' + days[0] + '</span>' +
                        '<span class="value">' + days[1] + '</span>' +
                    '</span> ' +
                    '<span class="what">days</span>' +
                '</div>' +
                '<div class="countdown-value hours">' +
                    '<span class="value-wrapper">' +
                        '<span class="value">' + hours[0] + '</span>' +
                        '<span class="value">' + hours[1] + '</span>' +
                    '</span> ' +
                    '<span class="what">hours</span>' +
                '</div> ' +
                '<div class="countdown-value minutes">' +
                    '<span class="value-wrapper">' +
                        '<span class="value">' + minutes[0] + '</span>' +
                        '<span class="value">' + minutes[1] + '</span>' +
                    '</span> ' +
                    '<span class="what">minutes</span>' +
                '</div> ' +
                '<div class="countdown-value seconds">' +
                    '<span class="value-wrapper">' +
                        '<span class="value">' + seconds[0] + '</span>' +
                        '<span class="value">' + seconds[1] + '</span>' +
                    '</span> ' +
                    '<span class="what">seconds</span>' +
                '</div>'
            ));
        }).on('finish.countdown', function(){
            $(this).html('Finished!')
        });
        $('.countdown-detail').removeClass('hidden');
    }

    $('[data-toggle="tooltip"]').tooltip({container: 'body'});

    var slideout = new Slideout({
        'panel': $('.main-panel')[0],
        'menu': $('.slideout-menu')[0],
        'padding': $('.slideout-menu').width(),
        'tolerance': 70,
        'touch': false
    });

    $('.js-slide-menu-open').click(function(){
        slideout.toggle();
    });
})
