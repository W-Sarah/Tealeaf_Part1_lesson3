$(document).ready(function() {

  $(document).on('click', '#hit_form input', function() {
    // alert("Player hits!");
    $.ajax({
      type: 'POST',
      url: '/game/player/hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });
  
    $(document).on('click', '#stay_form input', function() {
      // alert("Player stays!")
    $.ajax({
      type: 'POST',
      url: '/game/player/stay'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

    $(document).on('click', '#dealer_hit input', function() {
      // alert("Dealer hits!")
    $.ajax({
      type: 'POST',
      url: '/game/dealer/show'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

});