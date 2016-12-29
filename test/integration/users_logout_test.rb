require 'test_helper'

class UsersLogoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "it logs user out" do
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' }}
    follow_redirect!
    assert is_logged_in?
    assert_select "a[href=?]", logout_path
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # Simulate a user clicking logout in a second window.
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0

  end

  # test "the truth" do
  #   assert true
  # end
end
