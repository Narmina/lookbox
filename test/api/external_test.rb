require_relative '../test_helper'

describe External::ApiVersion1 do

  include Rack::Test::Methods
  include Warden::Test::Helpers

  def app
    External::ApiVersion1
  end

  before do
    header 'Content-Type', 'application/json'
  end

  let(:user_access_token) { 'asdf1337G' }
  let(:wrong_user_access_token) { '111' }

  def response_body
    JSON.parse(last_response.body)
  end

  describe "pictures list" do

   it "returns unauthorized for not existed user with api key" do
     get 'api/v1/pictures_list', {access_token: wrong_user_access_token}
     expect(last_response.status).must_equal 401
     expect(response_body['error']).must_match "Unauthorized"
    end
  end

   it "returns pictures list for user" do
     get 'api/v1/pictures_list', {access_token: user_access_token}
     expect(last_response.status).must_equal 200
  end

end