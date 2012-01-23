// AJAX load vm listing
$(function() {
  var url = $("#vms").attr('data-url');
  $('#vms').load(url + ' table');
});
