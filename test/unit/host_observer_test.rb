require 'test_helper'

class HostObserverTest < ActiveSupport::TestCase
  test "tokens should be removed based on build state" do
    disable_orchestration
    h = hosts(:one)
    as_admin do
      Setting[:token_duration] = 60
      assert_difference('Token.count') do
        h.build = true
        h.save!
      end
      assert_difference('Token.count', -1) do
        h.build = false
        h.save!
      end
    end
  end
end