$(document).ready(function($) {

  //   $("#suprise").click(function(){ // when click Sign Up button, hide the Log In elements, and display the Sign Up elements
  //     $("#suprise").toggleClass("active-button",false);
  //     $("#letMe").removeAttr("disabled");
  //     $(".tab-section").removeClass("active");
  //     $(".surpriseSection ").addClass("active");
  //     $("#letMe").toggleClass("active-button",true);
  //     $("#suprise").prop('disabled', true);
  // });
  //
  // $("#letMe").click(function(){ // when click Log In button, hide the Sign Up elements, and display the Log In elements
  //     $("#suprise").toggleClass("active-button",true);
  //     $("#letMe").prop('disabled', true);
  //     $(".surpriseSection").removeClass("active");
  //     $(".tab-section").addClass("active");
  //
  //     $("#letMe").toggleClass("active-button",false);
  //     $("#suprise").removeAttr("disabled");
  //
  // });


$(".button").on("click", function() {

    var $button = $(this);
    var oldValue = $button.parent().find("input").val();

    if ($button.text() == "+") {
      var newVal = parseFloat(oldValue) + 1;
    } else {
       // Don't allow decrementing below zero
      if (oldValue > 0) {
        var newVal = parseFloat(oldValue) - 1;
        } else {
        newVal = 0;
      }
      }

    $button.parent().find("input").val(newVal);

  });
});
