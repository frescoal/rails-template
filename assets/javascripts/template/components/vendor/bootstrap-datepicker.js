//
// Bootstrap Datepicker
//

'use strict';

let Datepicker = (function () {

  // Variables
  let $datepicker = $('.datepicker');

  // Methods
  function init($this) {
    let options = {
      disableTouchKeyboard: true,
      autoclose: true,
      language: 'fr'
    };

    $this.datepicker(options);

    $this.datepicker.dates.fr = {
      days: ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"],
      daysShort: ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"],
      daysMin: ["D", "L", "Ma", "Me", "J", "V", "S"],
      months: ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"],
      monthsShort: ["Jan", "Fév", "Mar", "Avr", "Mai", "Jui", "Jul", "Aou", "Sep", "Oct", "Nov", "Déc"],
      today: "Aujourd'hui",
      monthsTitle: "Mois",
      clear: "Effacer",
      weekStart: 1,
      format: "dd.mm.yyyy"
    }
  }

  // Events
  if ($datepicker.length) {
    $datepicker.each(function () {
      init($(this));
    });
  }
})();
