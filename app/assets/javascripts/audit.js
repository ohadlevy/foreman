$(document).ready(function () {
  // Row Checkbox Selection
  $("#pf-list-simple-expansion input[type='checkbox']").change(function (e) {
    if ($(this).is(":checked")) {
      $(this).closest('.list-group-item').addClass("active");
    } else {
      $(this).closest('.list-group-item').removeClass("active");
    }
  });
  // toggle dropdown menu
  $("#pf-list-simple-expansion .list-view-pf-actions").on('show.bs.dropdown', function () {
    var $this = $(this);
    var $dropdown = $this.find('.dropdown');
    var space = $(window).height() - $dropdown[0].getBoundingClientRect().top - $this.find('.dropdown-menu').outerHeight(true);
    $dropdown.toggleClass('dropup', space < 10);
  });

  // click the list-view heading then expand a row
  $("#pf-list-simple-expansion .list-group-item-header").click(function(event){
    if(!$(event.target).is("button, a, input, .fa-ellipsis-v")){
      $(this).find(".fa-angle-right").toggleClass("fa-angle-down")
        .end().parent().toggleClass("list-view-pf-expand-active")
          .find(".list-group-item-container").toggleClass("hidden");
    } else {
    }
  })
});

function revert_template_changes(element, audit_rec) {
  console.log($(element).data());
  var audit_rec = audit_rec.audit,
  element_data = $(element).data(),
  data_changes = {};

  if (element_data.hasOwnProperty('id')) {
    data_changes['id'] = element_data['id'];
  }
  var audited_changes = audit_rec.audited_changes;
  if ( audited_changes && !$.isEmptyObject(audited_changes)) {
    for (var attr_name in audited_changes) {
      data_changes[attr_name] = audited_changes[attr_name][0];
    }
    if (element_data['flink']) {
      $.ajax({
        url : element_data['flink'],
        data : JSON.stringify(data_changes),
        type : 'PUT',
        contentType : 'application/json',
        dataType: 'json',
        processData: false,
        success: function(response, status, xhr) {
          tfm.toastNotifications.notify({
            message: `<p>${response.message}</p>`,
            type: 'success',
          });
          window.location.href = response.success_redirect;
        },
        error: function(xhr, status, error) {
          response = JSON.parse(xhr.responseText);
          tfm.toastNotifications.notify({
            message: `<p>${response.message}</p>`,
            type: 'error',
          });
          window.location.href = response.success_redirect;
        }
      });
    }
  }
}
