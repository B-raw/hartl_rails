require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
   @user       = users(:michael)
   @other_user = users(:archer)
 end

 test "should get new" do
   get signup_url
   assert_response :success
 end

 test "should redirect index when not logged in" do
   get users_path
   assert_redirected_to login_url
 end

 test "should not be able to make a user an admin via web" do
   log_in_as(@other_user)
   assert_not @other_user.admin?
   patch user_path(@other_user), params: {
                                    user: { password:              "password",
                                            password_confirmation: "password",
                                            admin: true } }
   assert_not @other_user.reload.admin?
 end

 test "on deleting users, users who aren’t logged in should be redirected to the login page" do
   assert_no_difference 'User.count' do
      delete user_path(@user)
    end
   assert_redirected_to login_url
 end

 test "on deleting, non-admins should be redirected to the Home" do
   log_in_as(@other_user)
   assert_no_difference 'User.count' do
      delete user_path(@user)
    end
   assert_redirected_to root_url
 end

end
