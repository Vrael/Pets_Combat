module Pets
  class API < Grape::API
    version 'v1', using: :header, vendor: 'groopify'
    format :json
    prefix :api

    helpers do
      def authenticate!
        error!("401 Unauthorized", 401) unless current_user
      end

      def current_user
        params[:access_token] && @user = User.find_by_authentication_token(params[:access_token])
        @user
      end
    end


    resource :pets do

      desc "Return a pet."
        params do
          requires :id, type: Integer, desc: "Pet id."
        end
        route_param :id do
          get do
            pet = Pet.find_by_id(params[:id])
            error!("404 Not found", 404) if pet.nil?
            pet
          end
      end

      desc "Create a pet."
      params do
        requires :name,   type: String,   desc: 'Pet\'s name'
        requires :age,    type: Integer,  desc: 'Pet\'s age'
        requires :gender, type: String,   values: ['male', 'female']
        requires :kind,   type: String,   values: ['rat', 'dog', 'chinchilla']
      end
      post do
        authenticate!
        Pet.create!({
          user:   current_user,
          name:   params[:name],
          age:    params[:age],
          gender: params[:gender],
          kind:   params[:kind]
        })
      end

      desc "Update a pet."
      params do
        requires :id, type: String, desc: "Pet ID."
        requires :name,   type: String,   desc: 'Pet\'s name'
        requires :age,    type: Integer,  desc: 'Pet\'s age'
        requires :gender, type: String,   values: ['male', 'female']
        requires :kind,   type: String,   values: ['rat', 'dog', 'chinchilla']
      end
      put ':id' do
        authenticate!
        pet = current_user.pets.find_by_id(params[:id])
        error!("404 Not found", 404) if pet.nil?
        pet.update({
          user:   current_user,
          name:   params[:name],
          age:    params[:age],
          gender: params[:gender],
          kind:   params[:kind]
        })
      end

      desc "Delete a pet."
      params do
        requires :id, type: String, desc: "Pet ID."
      end
      delete ':id' do
        authenticate!
        pet = current_user.pets.find_by_id(params[:id])
        error!("404 Not found", 404) if pet.nil?
        pet.destroy
      end
    end
  end

end
