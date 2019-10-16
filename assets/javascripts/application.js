//= require js.cookie
//= require jquery
//= require_tree .


// Row can be clicked
$(".table > tbody").on("click", "tr", function (event) {
  if (event.target.nodeName !== "A" && event.target.nodeName !== "BUTTON") {
    if (!$(this).hasClass("no-link")) {
      if (event.ctrlKey) {
        window.open($(this).attr("href"), "_blank");
      } else {
        window.document.location = $(this).attr("href");
      }
    }
  }
});
