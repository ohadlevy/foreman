require 'test_helper'

class InterfaceTest < ActiveSupport::TestCase

  def setup
    disable_orchestration
  end

  test "should create simple interface" do
    i = ''
    assert_nothing_raised { i = NIC.create! :ip => "127.2.3.4", :mac => "cabbccddeeff", :host => hosts(:one), :name => hosts(:one).name }
    assert_equal "NIC", i.type

    assert_nothing_raised { i = Interface.create! :ip => "127.2.3.8", :mac => "babbccddeeff", :host => hosts(:one), :name => hosts(:one).name + "!", :role => "NIC" }
    assert_equal "NIC", i.type
  end

  test "should fail on invalid mac" do
    i = NIC.new :ip => "127.2.3.4", :mac => "abccddeeff", :host => hosts(:one)
    assert !i.valid?
  end

  test "should fix mac address" do
    interface = NIC.create! :ip => "127.2.3.4", :mac => "cabbccddeeff", :host => hosts(:one), :name => hosts(:one).name
    assert_equal "ca:bb:cc:dd:ee:ff", interface.mac
  end

  test "should fix ip address if a leading zero is used" do
    interface = NIC.create! :ip => "123.01.02.03", :mac => "dabbccddeeff", :host => hosts(:one), :name => hosts(:one).name
    assert_equal "123.1.2.3", interface.ip
  end

  test "should delegate subnet attributes" do
    subnet = subnets(:one)
    interface = NIC.create! :ip => "2.3.4.127", :mac => "cabbccddeeff", :host => hosts(:one), :subnet => subnet, :name => hosts(:one).name
    assert_equal subnet.network, interface.network
    assert_equal subnet.vlanid, interface.vlanid
  end
end
