$(document).ready(function () {
  var selection = $('select[id=image_uuid]');
  if (selection == [])
    return(false);

  selection.attr('disable', true);
  $('#image_uuid:input:hidden').select2({
    minimumInputLength: 1,
    id: function (object) {
      return object.text;
    },
    //Allow manually entered text in drop down.
    createSearchChoice: function (term, data) {
      if ($(data).filter(function () {
        return this.text.localeCompare(term) === 0;
      }).length === 0) {
        return {id: term, text: term};
      }
    },
    data: [
        {id: 0, text: 'story'},
        {id: 1, text: 'bug'},
        {id: 2, text: 'task'}
    ]
  });
});