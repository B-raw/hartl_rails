require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid form info on signup does not create user" do
    get signup_path
    assert_select "form[action='/signup']"
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar"}}
    end
    assert_template 'users/new'
  end

  test "invalid form gives correct error messages" do
    get signup_path
    assert_select "form[action='/signup']"
    post users_path, params: { user: { name: "",
                                       email: "user@invalid",
                                       password: "foo",
                                       password_confirmation: "bar"}}
    assert_select "div.alert", "The form contains 4 errors."
    assert_select "ul>li:nth-of-type(1)", "Name can't be blank"
    assert_select "ul>li:nth-of-type(2)", "Email is invalid"
    assert_select "ul>li:nth-of-type(3)", "Password is too short (minimum is 6 characters)"
    assert_select "ul>li:nth-of-type(4)", "Password confirmation doesn't match Password"
    assert_select 'div.field_with_errors'
  end

  test "valid user is saved" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "batman",
                                         email: "batman@gotham.com",
                                         password: "foobar",
                                         password_confirmation: "foobar"}}
      follow_redirect!
      assert_template 'users/show'
      assert_not flash.empty?
      assert is_logged_in?
    end
  end
end
