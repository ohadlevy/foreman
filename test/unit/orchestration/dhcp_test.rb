require 'test_helper'

class DhcpOrchestrationTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
  end

  def test_host_should_have_dhcp
    if unattended?
      h = hosts(:one)
      assert h.valid?
      assert h.dhcp?
      assert_instance_of Net::DHCP::Record, h.dhcp_record
    end
  end

  def test_host_should_not_have_dhcp
    if unattended?
      h = hosts(:minimal)
      assert h.valid?
      assert_equal false, h.dhcp?
    end
  end

  test "jumpstart parameter generation" do
    h = hosts(:sol10host)
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01").returns("2.3.4.5").once
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01.yourdomain.net").returns("2.3.4.5").once
    result = h.os.jumpstart_params h, h.model.vendor_class
    assert_equal result, {
      :vendor                => "<Sun-Fire-V210>",
      :install_path          => "/vol/solgi_5.10/sol10_hw0910_sparc",
      :install_server_ip     => "2.3.4.5",
      :install_server_name   => "brsla01",
      :jumpstart_server_path => "2.3.4.5:/vol/jumpstart",
      :root_path_name        => "/vol/solgi_5.10/sol10_hw0910_sparc/Solaris_10/Tools/Boot",
      :root_server_hostname  => "brsla01",
      :root_server_ip        => "2.3.4.5",
      :sysid_server_path     => "2.3.4.5:/vol/jumpstart/sysidcfg/sysidcfg_primary"
    }
  end

  test "new host should create a dhcp reservertion" do
    h = hosts(:dhcp).clone
    assert h.new_record?
    h.name = "dummy-123"
    h.ip = "2.3.4.101"
    h.mac = "bb:bb:bb:bb:bb:bb"
    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action.last == :set_dhcp }.size, 1
    assert h.queue.items.select {|x| x.action.last == :del_dhcp }.empty?
  end

  test "new host should create a BMC dhcp reservertion" do
    User.current = users(:admin)
    h            = hosts(:dhcp).clone
    assert h.new_record?
    h.name                  = "dummy-123"
    h.ip                    = "2.3.4.101"
    h.mac                   = "bb:bb:bb:bb:bb:bb"
    h.interfaces_attributes = [{ :name => "dummy-bmc", :ip => "2.3.4.102", :mac => "aa:bb:cd:cd:ee:ff", :subnet => h.subnet, :provider => 'IPMI', :type => 'BMC' }]
    assert h.save
    bmc = h.interfaces.detect { |i| i.name == 'dummy-bmc' }

    host_tasks      = h.queue.items.select { |t| t.action.first == h }
    interface_tasks = h.queue.items.select { |t| t.action.first == bmc }

    assert_equal host_tasks.select      { |t| t.action.last == :set_dhcp }.size, 1
    assert host_tasks.select            { |t| t.action.last == :del_dhcp }.empty?
    assert_equal interface_tasks.select { |t| t.action.last == :set_dhcp }.size, 1
    assert interface_tasks.select       { |t| t.action.last == :del_dhcp }.empty?
  end

  test "existing host should not change any dhcp settings" do
    h = hosts(:dhcp)
    assert h.valid?
    assert_equal h.ip, h.old.ip
    assert_equal h.mac, h.old.mac
    assert_equal h.name, h.old.name
    assert_equal h.subnet, h.old.subnet
    assert h.queue.items.select {|x| x.action.last =~ /dhcp/ }.empty?
  end

  test "existing host should not change any bmc dhcp settings" do
    h = hosts(:sp_dhcp)
    assert h.valid?
    assert_equal h.sp_ip, h.old.sp_ip
    assert_equal h.sp_mac, h.old.sp_mac
    assert_equal h.sp_name, h.old.sp_name
    assert_equal h.sp_subnet, h.old.sp_subnet
    assert h.queue.items.select {|x| x.action.last =~ /sp_dhcp/ }.empty?
  end

  test "when an existing host change its ip address, its dhcp record should be updated" do
    h = hosts(:dhcp)
    h.ip = "2.3.4.101"
    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action == [ h,     :set_dhcp ] }.size, 1
    assert_equal h.queue.items.select {|x| x.action == [ h.old, :del_dhcp ] }.size, 1
  end

  test "when an existing host change its bmc ip address, its dhcp record should be updated" do
    h = hosts(:sp_dhcp)
    bmc = h.interfaces.bmc.first
    bmc.ip = "2.3.4.101"
    assert bmc.valid?
    assert h.valid?
    assert_equal bmc.queue.items.select {|x| x.action == [ bmc,     :set_dhcp ] }.size, 1
    assert_equal bmc.queue.items.select {|x| x.action == [ bmc.old, :del_dhcp ] }.size, 1
  end

  test "when an existing host change its mac address, its dhcp record should be updated" do
    h = hosts(:dhcp)
    h.mac = "aa:aa:aa:bb:bb:dd"
    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action == [ h,     :set_dhcp ] }.size, 1
    assert_equal h.queue.items.select {|x| x.action == [ h.old, :del_dhcp ] }.size, 1
  end

  test "when an existing host change its bmc mac address, its dhcp record should be updated" do
    h = hosts(:sp_dhcp)
    (bmc = h.interfaces.bmc.first).mac = "aa:aa:aa:ab:bb:bb"
    assert bmc.valid?
    assert h.valid?
    assert_equal bmc.queue.items.select {|x| x.action == [ bmc,     :set_dhcp ] }.size, 1
    assert_equal bmc.queue.items.select {|x| x.action == [ bmc.old, :del_dhcp ] }.size, 1
  end

  test "when an existing host change multiple attributes, both his dhcp and bmc dhcp records should be updated" do
    h = hosts(:sp_dhcp)
    h.mac = "aa:aa:aa:bb:bb:dd"
    (bmc=h.interfaces.bmc.first).name = "BMC-it"
    assert bmc.valid?
    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action == [ h,     :set_dhcp ] }.size, 1
    assert_equal h.queue.items.select {|x| x.action == [ h.old, :del_dhcp ] }.size, 1
    assert_equal bmc.queue.items.select {|x| x.action == [ bmc,     :set_dhcp ] }.size, 1
    assert_equal bmc.queue.items.select {|x| x.action == [ bmc.old, :del_dhcp ] }.size, 1
  end

end
