require "test_helper"

class BreadcrumOptionsTest < ActiveSupport::TestCase
  def setup
  end

  test "it should provide default breadcrumb options" do
    page_header = "a page"
    controller_name = "SomePage"
    action_name = "show"
    options = BreadcrumOptions.new(page_header, controller_name, action_name, {})

    assert_equal options.bar_props, {
      isSwitchable: true,
      breadcrumbItems: [
        {
          caption: "Somepage",
          url: nil
        },
        {
          caption: "a page"
        }
      ],
      resource:
      {
        switcherItemUrl: "/SomePage/:id/",
        resourceUrl: "/api/v2/SomePage",
        nameField: "name"
      }
    }

  end
end
