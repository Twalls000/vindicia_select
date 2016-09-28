ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/mock"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # The verify_run lambda is called when klass::method, the stubbed method, is
  # called in the block. This lambda changes the value of test_var, thus
  # ensuring that klass::method was called.
  def verify_class_method(klass,method,&block)
    test_var = false
    verify_run = ->{
      test_var = true
    }
    klass.stub(method.to_sym, verify_run) do
      yield block
    end
    assert test_var
  end
end
