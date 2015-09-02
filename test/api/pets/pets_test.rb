require "test_helper"

class Pets::APITest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def get_req(id)
    get "/api/pets/#{id}", {}, 'CONTENT_TYPE' => 'application/json' 
  end

  def post_req(data)
    post '/api/pets', data.to_json, 'CONTENT_TYPE' => 'application/json' 
  end

  def put_req(id, data)
    put "/api/pets/#{id}", data.to_json, 'CONTENT_TYPE' => 'application/json' 
  end

  def delete_req(id, data)
    delete "/api/pets/#{id}", data.to_json, 'CONTENT_TYPE' => 'application/json' 
  end

  test 'GET /api/pets/:id with valid id' do
    pikachu = pets(:pikachu)
    
    get_req pikachu.id
    
    assert last_response.ok?
    pet = JSON.parse last_response.body

    assert_equal pet.to_json, pikachu.to_json
  end
  
  test 'GET /api/pets/:id with invalid id' do
    get_req -1
    
    assert !last_response.ok?
    assert_equal 404, last_response.status
  end

  test 'POST /api/pets creates a pet' do
    data = {
      access_token: users(:fran).authentication_token,
      name: 'pikachu',
      age:  12
    }

    # Allow values
    genders = ['male','female']
    kind = ['rat','dog','chinchilla']

    # Post for each value
    genders.each do |gender|
      data[:gender] = gender 
      
      kind.each do |kind|
        data[:kind] = kind 
      
        post_req(data)
        assert_equal 201, last_response.status
      end
    end
  end
  
  test 'POST /api/pets with access_token missing' do
    data = {
      name: 'zapdos',
      age:  12,
      gender: 'male',
      kind: 'dog'
    }

    post_req data
    assert !last_response.ok?
    assert_equal 401, last_response.status
  end

  test 'POST /api/pets with missing parameters' do
    # No param
    data = {
      access_token: users(:fran).authentication_token
    }

    post_req data
    assert !last_response.ok?
    assert_equal 400, last_response.status
 
    msg_error = JSON.parse(last_response.body)['error']
 
    assert_match /name is missing/, msg_error
    assert_match /age is missing/, msg_error
    assert_match /gender is missing/, msg_error
    assert_match /kind is missing/, msg_error

    # With Name param
    data[:name] = 'bulbasur'
    post_req data
    assert_equal 400, last_response.status
    msg_error = JSON.parse(last_response.body)['error']
    assert_no_match /name is missing/, msg_error
    assert_match /age is missing/, msg_error
    assert_match /gender is missing/, msg_error
    assert_match /kind is missing/, msg_error

    # With Name & Age params
    data[:age] = '4'
    post_req data
    assert_equal 400, last_response.status
    msg_error = JSON.parse(last_response.body)['error']
    assert_no_match /name is missing/, msg_error
    assert_no_match /age is missing/, msg_error
    assert_match /gender is missing/, msg_error
    assert_match /kind is missing/, msg_error
    
    # With Name & Age & Gender params
    data[:gender] = 'famele'
    post_req data
    assert_equal 400, last_response.status
    msg_error = JSON.parse(last_response.body)['error']
    assert_no_match /name is missing/, msg_error
    assert_no_match /age is missing/, msg_error
    assert_no_match /gender is missing/, msg_error
    assert_match /kind is missing/, msg_error
    
    # With Name & Age & Gender & Kind params
    data[:kind] = 'rat'
    post_req data
    assert_equal 400, last_response.status
    msg_error = JSON.parse(last_response.body)['error']
    assert_no_match /name is missing/, msg_error
    assert_no_match /age is missing/, msg_error
    assert_no_match /gender is missing/, msg_error
    assert_no_match /kind is missing/, msg_error
  end
  
  test 'POST /api/pets with wrong gender value' do
    data = {
      access_token: users(:fran).authentication_token,
      name: 'pikachu',
      age:  2,
      gender: 'only_famele_or_male',
      kind: 'only_rat_dog_or_chinchilla'
    }

    post_req data
    msg_error = JSON.parse(last_response.body)['error']

    assert !last_response.ok?
    assert_equal 400, last_response.status

    assert_match /gender does not have a valid value/, msg_error
    assert_match /kind does not have a valid value/, msg_error
  end
  
  test 'PUT /api/pets/:id with valid data' do
    data = {
      access_token: users(:fran).authentication_token,
      name: 'pikachu',
      age:  12,
      gender: 'male',
      kind: 'dog'
    }

    put_req pets(:pikachu).id, data
    assert last_response.ok?
    assert_equal 200, last_response.status
  end
  
  test 'PUT /api/pets/:id with without token' do
    data = {
      name: 'zapdos',
      age:  12,
      gender: 'male',
      kind: 'dog'
    }

    put_req pets(:pikachu).id, data
    assert !last_response.ok?
    assert_equal 401, last_response.status
  end
  
  test 'PUT /api/pets/:id with other user\'s pet' do
    data = {
      access_token: users(:mark).authentication_token,
      name: 'pikachu',
      age:  12,
      gender: 'male',
      kind: 'dog'
    }

    put_req pets(:pikachu).id, data
    # Pickachu is from Fran, not from Mark
    
    assert !last_response.ok?
    assert_equal 404, last_response.status
  end
  
  test 'DELETE /api/pets/:id a pet' do
    data = {
      access_token: users(:fran).authentication_token
    }

    delete_req pets(:pikachu).id, data
    assert last_response.ok?
    assert_equal 200, last_response.status
  end
  
  test 'DELETE /api/pets/:id without token' do
    data = {}

    delete_req pets(:pikachu).id, data
    assert !last_response.ok?
    assert_equal 401, last_response.status
  end
  
  test 'DELETE /api/pets/:id other user\'s pet' do
    data = {
      access_token: users(:mark).authentication_token
    }

    delete_req pets(:pikachu).id, data
    # Pickachu is from Fran, not from Mark
    
    assert !last_response.ok?
    assert_equal 404, last_response.status
  end
end
