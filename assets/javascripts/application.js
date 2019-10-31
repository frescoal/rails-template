//= require js.cookie
//= require jquery
//= require cocoon
//= require_tree .
//= require jquery.dataTables.min
//= require dataTables.bootstrap4.min
//= require dataTable.moment

$(document).ready(function () {
  $.fn.dataTable.moment("DD.MM.YYYY");

  $(".default_grid").DataTable({
    info: false,
    bLengthChange: false,
    bFilter: true,
    bSort: true,
    "searching": true,
    "pagingType": "full_numbers",
    language: {
      url: "//cdn.datatables.net/plug-ins/1.10.11/i18n/French.json"
    },
    paginate: {
      previous: "<i class='fas fa-angle-left'>",
      next: "<i class='fas fa-angle-right'>"
    },
    "fnDrawCallback": function (oSettings) {
      if (oSettings._iDisplayLength > oSettings.fnRecordsDisplay()) {
        $(oSettings.nTableWrapper).find(".dataTables_paginate").hide();
      } else {
        $(oSettings.nTableWrapper).find(".dataTables_paginate").show();
      }
    },
  });
});
