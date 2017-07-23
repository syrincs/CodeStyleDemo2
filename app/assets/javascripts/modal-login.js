$(document).ready(function () {
  var $form = $("#modal-login-form");

  $form.on("ajax:complete", function(e, xhr, status) {
    var response = xhr.responseJSON;
    var $form = $(e.target);
    var $modal = $form.closest(".modal");

    if (response.success) {
      window.location = window.location + "?click=" + $form.data("click-after-login");
      return false;
    }

    // error
    $form.addClass("has-error");
    $modal.find('.help-block').text(response.message);
  });
});
