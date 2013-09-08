require 'test_helper'

class Api::V2::OverrideValuesControllerTest < ActionController::TestCase

  smart_variable_attrs = { :match => 'xyz=10', :value => '8433' }
  smart_class_attrs = { :match => 'host=abc.com', :value => 'liftoff' }

  test "should get override values for specifc smart variable" do
    get :index, {:smart_variable_id => lookup_keys(:one).to_param }
    assert_response :success
    override_values = ActiveSupport::JSON.decode(@response.body)
    assert !override_values.empty?
    assert_equal 3, override_values["override_values"].length
  end
  test "should get override values for specifc smart class parameter" do
    get :index, {:smart_class_parameter_id => lookup_keys(:complex).to_param }
    assert_response :success
    override_values = ActiveSupport::JSON.decode(@response.body)
    assert !override_values.empty?
    assert_equal 2, override_values["override_values"].length
  end

  test "should create override values for specifc smart variable" do
    assert_difference('LookupValue.count') do
      post :create,  {:smart_variable_id => lookup_keys(:one).to_param, :override_value => smart_variable_attrs }
    end
    assert_response :success
  end
  test "should create override values for specifc smart class parameter" do
    assert_difference('LookupValue.count') do
      post :create,  {:smart_class_parameter_id => lookup_keys(:complex).to_param, :override_value => smart_class_attrs }
    end
    assert_response :success
  end

  test "should show specific override values for specifc smart variable" do
    get :show,  {:smart_variable_id => lookup_keys(:one).to_param, :id => lookup_values(:one).to_param }
    assert_response :success
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['override_value'].empty?
    assert_equal "fqdn=my5name.mydomain.net", results['override_value']['match']
  end
  test "should show specific override values for specifc smart class parameter" do
    get :show,  {:smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).to_param }
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['override_value'].empty?
    assert_equal "hostgroup=Common", results['override_value']['match']
    assert_response :success
  end


  # test "should get puppetclasses for hostgroup" do
  #   get :index, {:hostgroup_id => hostgroups(:common).to_param }
  #   assert_response :success
  #   puppetclasses = ActiveSupport::JSON.decode(@response.body)
  #   assert !puppetclasses.empty?
  #   assert_equal 1, puppetclasses.length
  # end

  # test "should get puppetclasses for environment" do
  #   get :index, {:environment_id => environments(:production).to_param }
  #   assert_response :success
  #   puppetclasses = ActiveSupport::JSON.decode(@response.body)
  #   assert !puppetclasses.empty?
  #   assert_equal 2, puppetclasses.length
  # end

  # test "should show puppetclass for host" do
  #   get :show, { :host_id => hosts(:one).to_param, :id => puppetclasses(:one).id }
  #   assert_response :success
  #   show_response = ActiveSupport::JSON.decode(@response.body)
  #   assert !show_response.empty?
  # end

  # test "should show puppetclass for hostgroup" do
  #   get :show, { :hostgroup_id => hostgroups(:common).to_param, :id => puppetclasses(:one).id }
  #   assert_response :success
  #   show_response = ActiveSupport::JSON.decode(@response.body)
  #   assert !show_response.empty?
  # end

  # test "should show puppetclass for environment" do
  #   get :show, { :environment_id => environments(:production), :id => puppetclasses(:one).id }
  #   assert_response :success
  #   show_response = ActiveSupport::JSON.decode(@response.body)
  #   assert !show_response.empty?
  # end

  # test "should give error if puppetclass is not in nested host" do
  #   get :show, { :host_id => hosts(:one).to_param, :id => puppetclasses(:four).id }
  #   assert_response :error
  # end

  # test "should give error if puppetclass is not in nested hostgroup" do
  #   get :show, { :hostgroup_id => hostgroups(:common).to_param, :id => puppetclasses(:four).id }
  #   assert_response :error
  # end

  # test "should give error if puppetclass is not in nested environment" do
  #   get :show, { :environment_id => environments(:production).to_param, :id => puppetclasses(:four).id }
  #   assert_response :error
  # end

  # # CRUD actions - same test as V1
  # test "should get index" do
  #   get :index, { }
  #   assert_response :success
  #   puppetclasses = ActiveSupport::JSON.decode(@response.body)
  #   assert !puppetclasses.empty?
  # end

  # # FYI - show puppetclass doesn't work in V1
  # test "should show puppetclass with no nesting" do
  #   get :show, { :id => puppetclasses(:one).to_param }
  #   assert_response :success
  #   show_response = ActiveSupport::JSON.decode(@response.body)
  #   assert !show_response.empty?
  # end

  # test "should create puppetclass" do
  #   assert_difference('Puppetclass.count') do
  #     post :create, { :puppetclass => valid_attrs }
  #   end
  #   assert_response :success
  # end

  # test "should update puppetclass" do
  #   put :update, { :id => puppetclasses(:one).to_param, :puppetclass => { } }
  #   assert_response :success
  # end

  # test "should destroy puppetclasss" do
  #   HostClass.delete_all
  #   HostgroupClass.delete_all
  #   assert_difference('Puppetclass.count', -1) do
  #     delete :destroy, { :id => puppetclasses(:one).to_param }
  #   end
  #   assert_response :success
  # end

end