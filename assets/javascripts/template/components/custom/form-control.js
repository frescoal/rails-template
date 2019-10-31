//
// Form control
//

'use strict';

let FormControl = (function() {

	// Variables

	let $input = $('.form-control');

	// Methods

	function init($this) {
		$this.on('focus blur', function(e) {
        $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
    }).trigger('blur');
	}


	// Events
	if ($input.length) {
		init($input);
	}

})();


let InputFile = (function() {

  // Variables
  let $input = $('.custom-file-input');

  // Methods
  function init($this) {
    $this.on('change',function(){
      // Get the file name
      let fileName = $this.val();

      // Replace the "Choose a file" label
      $this.next('.custom-file-label').html(fileName);
    });
  }


  // Events
  if ($input.length) {
    init($input);
  }

})();


