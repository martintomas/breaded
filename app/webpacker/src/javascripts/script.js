// $(document).ready(function($) {

//     $("#suprise").click(function(){ // when click Sign Up button, hide the Log In elements, and display the Sign Up elements
//       $("#suprise").toggleClass("active-button",false);
//       $("#letMe").removeAttr("disabled");
//       $(".tab-section").removeClass("active");
//       $(".surpriseSection ").addClass("active");
//       $("#letMe").toggleClass("active-button",true);
//       $("#suprise").prop('disabled', true);
//   });
//
//   $("#letMe").click(function(){ // when click Log In button, hide the Sign Up elements, and display the Log In elements
//       $("#suprise").toggleClass("active-button",true);
//       $("#letMe").prop('disabled', true);
//       $(".surpriseSection").removeClass("active");
//       $(".tab-section").addClass("active");
//
//       $("#letMe").toggleClass("active-button",false);
//       $("#suprise").removeAttr("disabled");
//
//   });
//
//     $(".lastWord").html(function(){
//         var text= $(this).text().trim().split(" ");
//         var last = text.pop();
//         return text.join(" ") + (text.length > 0 ? " <span class='lastwordsplit'>" + last + "</span>" : last);
//       });
//
//
// $(".button").on("click", function() {
//
//     var $button = $(this);
//     var oldValue = $button.parent().find("input").val();
//
//     if ($button.text() == "+") {
//       var newVal = parseFloat(oldValue) + 1;
//     } else {
//        // Don't allow decrementing below zero
//       if (oldValue > 0) {
//         var newVal = parseFloat(oldValue) - 1;
//         } else {
//         newVal = 0;
//       }
//       }
//
//     $button.parent().find("input").val(newVal);
//
//   });
//
//
//   $(".filterSetion > .bakersBread li").click(function(){
//     $(".filterSetion > .bakersBread li").toggleClass("active");
//     $(".itemsBlock,.listItems,.dropdown").toggleClass("active");
//     $(".selectedBreadsActive").toggleClass("active");
//   });
//
//   $("#bakers").click(function(){
//     $(".dd").replaceWith('<span class="dd">Slice</span>');
//   });
//
//   $("#breads").click(function(){
//     var listValue = $(".breadsList .active").text();
//     $(".dd").replaceWith('<span class="dd">' + listValue + '</span>');
//   });
// });

// $(document).ready(function() {
//     var s = $("#container");
//   var pos = s.position();
//
//   console.log(pos);
//     $(window).scroll(function() {
//     var windowpos = $(window).scrollTop();
//     var contentHeight = $(".itemsBlock").height() - 100;
//         if (windowpos >= 300 & windowpos <= contentHeight) {
//             $('.sticker').addClass("stick");
//         } else {
//             $('.sticker').removeClass("stick");
//     }
//
//
//   });


  

  // $("#dd").click(function() {
  //   $('.wrapper-dropdown-3').toggleClass('active');
  // });
  //
  // $(".breadsList li").click(function() {
  //   var listValue = $(this).text();
  //   $(".dd").replaceWith('<span class="dd">' + listValue + '</span>');
  //   $(this).addClass('active').siblings().removeClass('active');
  // });
  //
  // $(".wrapper-dropdown-3 .breadsListMob li").click(function(){
  //   var listValue = $(this).text();
  //     $(".dd").replaceWith('<span class="dd">' + listValue + '</span>');
  //      $('.wrapper-dropdown-3').toggleClass('active');
  // });


//});
