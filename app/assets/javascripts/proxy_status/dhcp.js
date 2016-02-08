function activateDhcpTables() {
  showProxies();
  setTab();
  loadSubnetOnContentLoad();
  loadSubnetOnClick();
}

// fetch leases and reservations when there is an anchor to a subnet details on page load
function loadSubnetOnContentLoad() {
  var anchor = document.location.hash;
  anchor = anchor.slice(1, anchor.length);

  if (/^(\d{1,3}-){3}\d{1,3}$/.test(anchor)) {
    var element = $("#proxy-dhcp-tab").find('[data-placeholder=' + anchor + ']').first();
    loadSubnet(element);
  }
}

function loadSubnet(element) {
  var url = $(element).data('url'),
      network = $(element).data('placeholder'),
      netmask = $(element).data('netmask'),
      placeholder = $('#subnet-placeholder-' + network).first();
  network = network.replace(/-/g, '.');
  hideHosts(placeholder);
  showSpinners();
  $.ajax({
    type: 'get',
    url: url,
    data: {network: network, netmask: netmask},
    success: function (response) {
      $(response).insertAfter(placeholder);
      activateDatatables();
      hideSpinners();
    },
    error: function (response) {
      var div = $("<div class='top-margin'></div>");
      div.append($(response.responseText));
      div.insertAfter(placeholder);
      hideSpinners();
    }
  });
}

function loadSubnetOnClick() {
  $('.subnet-menu').each(function (index, item) {
    $(item).click(function () {
      loadSubnet(this);
    })
  });
}

function showSpinners() {
  $('.subnet-spinner').show();
}

function hideSpinners() {
  $('.subnet-spinner').hide();
}

function hideHosts(placeholder) {
  placeholder.next().remove();
}
