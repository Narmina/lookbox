ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
# require "minitest/spec"
# require "minitest/autorun"
require 'minitest/rails/capybara'
require 'sidekiq/testing'
Sidekiq::Testing.fake!  # by default it is fake

#ENV['RACK_ENV'] = 'test'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  extend MiniTest::Spec::DSL

  after(:all) do
    if Rails.env.test?
      FileUtils.rm_rf(Dir["#{Rails.root}/public/uploads/test/[^.]*"])
    end
  end

end


if defined?(CarrierWave)
  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      def cache_dir
        "#{Rails.root}/public/uploads/test"
      end

      def store_dir
        "#{Rails.root}/public/uploads/test/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end
    end
  end
end

