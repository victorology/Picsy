require 'test/test_helper'

class PersonalizationControllerTest < ActionController::TestCase
  fixtures :all
  # Replace this with your real tests.
  test "user creation via API" do
    post "user_creation", :user => {
      :nickname => "kevin",
      :email => "kevin@gmail.com",
      :password => "demo1234",
      :format => "json"
    }
    assert_response :success
  end
end
