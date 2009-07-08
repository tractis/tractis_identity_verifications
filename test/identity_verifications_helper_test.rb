require 'test_helper'

class Controller < ActionController::Base
  include ActionView::Helpers
  include Tractis::Helpers::IdentityVerifications
  
  attr_accessor :output_buffer
end

class Helpers::IdentityVerificationsTest < ActiveSupport::TestCase
  include ActionController::Assertions::TagAssertions
  include ActionView::Helpers
  
  def setup
    @controller = Controller.new
    @controller.output_buffer = ""
  end
  
  test "form_for_identity_verification_gateway form tag" do
    form = @controller.form_for_identity_verification_gateway("", "") { }
    assert_tag(form, :form, :attributes => {:action => "https://www.tractis.com/verifications", :method => 'post'})
  end
  
  test "form_for_identity_verification_gateway api_key input" do
    form = @controller.form_for_identity_verification_gateway("my-api-key", "") { }
    assert_tag(form, :input, :attributes => {:type => 'hidden', :name => 'api_key', :value => 'my-api-key'}, :parent => {:tag => "form"})
  end
  
  test "form_for_identity_verification_gateway notification_callback input" do
    @controller.expects(:url_for).with(anything)
    @controller.expects(:url_for).with("/url").returns("/url")
    form = @controller.form_for_identity_verification_gateway("", "/url") { }
    assert_tag(form, :input, :attributes => {:type => 'hidden', :name => 'notification_callback', :value => '/url'}, :parent => {:tag => "form"})
  end
  
  test "form_for_identity_verification_gateway notification_callback input forces use_path => false in url_for" do
    @controller.expects(:url_for).with(anything)
    @controller.expects(:url_for).with({:action => 'create', :controller => 'verifications', :only_path => false})
    form = @controller.form_for_identity_verification_gateway("", {:action => 'create', :controller => 'verifications'}, :parent => {:tag => "form"}) { }
  end
  
  test "form_for_identity_verification_gateway doesn't add public_verification by default" do
    form = @controller.form_for_identity_verification_gateway("", "") { }
    assert_no_tag(form, :input, :attributes => {:type => 'hidden', :name => 'public_verification'})
  end
  
  test "form_for_identity_verification_gateway with public_verification" do
    form = @controller.form_for_identity_verification_gateway("", "", :public_verification => true) { }
    assert_tag(form, :input, :attributes => {:type => 'hidden', :name => 'public_verification', :value => 'true'}, :parent => {:tag => "form"})
  end
  
  test "form_for_identity_verification_gateway captures a block" do
    form = @controller.form_for_identity_verification_gateway("", "", :public_verification => true) do
      submit_tag("Identify using eID")
    end
    assert_tag(form, :input, :attributes => {:type => 'submit', :name => 'commit', :value => 'Identify using eID'}, :parent => {:tag => "form"})
  end
  
  test "identity_verification_gateway uses form_for_identity_verification_gateway" do
    @controller.expects(:form_for_identity_verification_gateway).with("api-key", "url", {:options => true})
    form = @controller.identity_verification_gateway("identify yourself", "api-key", "url", {:options => true})
  end
  
  test "identity_verification_gateway" do
    form = @controller.identity_verification_gateway("identify yourself", "api-key", "url", {:options => true})
    assert_tag(form, :input, :attributes => {:type => 'submit', :name => 'commit', :value => "identify yourself"}, :parent => {:tag => "form"})
  end
  
  def find_tag(conditions)
    HTML::Document.new(@response.body, false, false).find(conditions)
  end
  
  def assert_tag_with_content(content, *conditions)
    @response = stub("response", :body => content)
    assert_tag_without_content(*conditions)
  end
  alias_method_chain :assert_tag, :content
  
  def assert_no_tag_with_content(content, *conditions)
    @response = stub("response", :body => content)
    assert_no_tag_without_content(*conditions)
  end
  alias_method_chain :assert_no_tag, :content
  
  def clean_backtrace(&block)
    yield
  end
end
