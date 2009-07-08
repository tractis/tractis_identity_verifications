require 'test_helper'

class Controller < ActionController::Base
  include Tractis::IdentityVerifications
  
  def validate(params={})
    valid_tractis_identity_verification!("api-key", params)
  end
end

class IdentityVerificationsTest < ActiveSupport::TestCase
  def setup
    @controller = Controller.new
  end
  
  test "valid_tractis_identity_verification raises InvalidVerificationError exception for invalid verification" do
    Tractis::HTTP.stubs(:Request).returns(stub('response', :code => 400))
    assert_raise(Tractis::InvalidVerificationError) {
      @controller.validate
    }
  end
  
  test "valid_tractis_identity_verification returns true when tractis respones is 200 OK" do
    Tractis::HTTP.stubs(:Request).returns(stub('response', :code => 200))
    result = @controller.validate
    assert_equal(true, result)
  end
  
  test "valid_tractis_identity_verification is a private method from the controller" do
    assert(@controller.private_methods.include?("valid_tractis_identity_verification!"), "valid_tractis_identity_verification! methd should be a private method from the controller")
  end
  
  test "valid_tractis_identity_verification checking with tractis" do
    Tractis::HTTP.expects(:Request).with(:POST, '/data_verification', {:api_key => 'api-key', :one => 1, :two => 2}).returns(stub('response', :code => 200))
    params = {
      :one => 1,
      :two => 2,
      :controller => 'default',
      :action => 'index',
      :format => 'js'
    }
    @controller.validate(params)
  end
end
