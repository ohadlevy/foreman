require "test_helper"

class PuppetClassImporterTest < ActiveSupport::TestCase

  def setup
    ProxyAPI::Puppet.any_instance.stubs(:environments).returns(["production"])
    ProxyAPI::Puppet.any_instance.stubs(:classes).returns(mocked_classes)
  end


  test "proxy should be a only allow real proxy object" do
    assert_raise RuntimeError do
      PuppetClassImporter.new(:proxy => Object.new)
    end
  end

  test "should support providing proxy" do
    proxy = smart_proxies(:puppetmaster)
    klass = PuppetClassImporter.new(:proxy => ProxyAPI::Puppet.new(:url => proxy.url))
    assert_kind_of ProxyAPI::Puppet, klass.send(:proxy)
  end

  test "should support providing url" do
    proxy = smart_proxies(:puppetmaster)
    klass = PuppetClassImporter.new(:url => proxy.url)
    assert_equal proxy.url, klass.send(:url)
  end

  test "should return list of envs" do
    assert_kind_of Array, get_an_instance.db_environments
  end

  test "should return list of actual puppet envs" do
    assert_kind_of Array, get_an_instance.actual_environments
  end

  test "should return list of classes" do
    importer = get_an_instance
    assert_kind_of Array, importer.db_classes(importer.db_environments.first)
  end

  test "should return list of actual puppet classes" do
    importer = get_an_instance
    assert_kind_of Array, importer.actual_classes(importer.actual_environments.first)
  end

  private

  def get_an_instance
    PuppetClassImporter.new :url => smart_proxies(:puppetmaster).url
  end

  def mocked_classes
    [{
       "apache::service" => {
         "name"   => "service",
         "params" => { "port" => "80", "version" => "2.0" },
         "module" => "apache"
       }
     }]
  end

end