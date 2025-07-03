require "test_helper"

class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get verify" do
    get email_verifications_verify_url
    assert_response :success
  end

  test "should get resend" do
    get email_verifications_resend_url
    assert_response :success
  end
end
