require "test_helper"

class Combat::APITest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def post_req(data)
    post '/api/combat', data.to_json, 'CONTENT_TYPE' => 'application/json' 
  end

  test 'POST /api/combats with allow data' do
    data = {
      access_token: users(:fran).authentication_token,
      pet1_id: pets(:pikachu).id,
      pet2_id: pets(:ivisur).id,
      datetime: DateTime.now + 1
    } # These pets are rest 24h from last combat

    post_req data
    assert_equal 201, last_response.status
  end
  
  test 'POST /api/combats with not rested pets' do
    # No rested any pet
    data = {
      access_token: users(:fran).authentication_token,
      pet1_id: pets(:charmeleon).id,
      pet2_id: pets(:kakuna).id,
      datetime: DateTime.now + 1
    }

    post_req data
    assert_equal 412, last_response.status

    # Only one pet rested
    data[:pet1_id] = pets(:charmeleon).id
    data[:pet2_id] = pets(:pikachu).id

    post_req data 
    assert_equal 412, last_response.status
    
    # Only one pet rested (bis)
    data[:pet1_id] = pets(:kakuna).id
    data[:pet2_id] = pets(:charmeleon).id

    post_req data 
    assert_equal 412, last_response.status
  end
  
  test 'POST /api/combats with datetime before than current datetime' do
    data = {
      access_token: users(:fran).authentication_token,
      pet1_id: pets(:pikachu).id,
      pet2_id: pets(:ivisur).id,
      datetime: DateTime.now - 1
    } # These pets are rest 24h from last combat

    post_req data
    assert !last_response.ok?
    assert_equal 400, last_response.status
  end
end

