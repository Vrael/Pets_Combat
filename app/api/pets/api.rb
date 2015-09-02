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

      def pet_rest_24h?(pet)
        combats = Combat.where("pet1_id = ? OR pet2_id = ?", pet.id, pet.id).order(date: :desc)
        unless combats.empty?
          combat = combats.first 
          DateTime.now.utc - combat.date.to_datetime.utc >= 1
        else
          true 
        end
      end
    end

    class FutureDateTime < Grape::Validations::Base
      def validate_param!(attr_name, params)
        if  params[attr_name].utc - DateTime.now.utc < 0
          fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "The datetime must be future"
        end
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

    resource :combat do
      desc "Create a combat."
      params do
        requires :pet1_id, type: Integer,   desc: 'Pet\'s id'
        requires :pet2_id, type: Integer,   desc: 'Pet\'s id'
        requires :datetime, type: DateTime, future_date_time: true,  desc: 'Date and time of the combat'
      end
      post do
        authenticate!
        pet1 = Pet.find_by_id(params[:pet1_id])
        pet2 = Pet.find_by_id(params[:pet2_id])

        error!("404 Not found", 404) if pet1.nil?
        error!("404 Not found", 404) if pet2.nil?
        error!("412 Pets cannot both belongs to the same user", 412) if pet1.user == pet2.user
        error!("412 One of the pets has not rested 24h yet", 412) if !pet_rest_24h?(pet1) or !pet_rest_24h?(pet2)

        Combat.create!({
          pet1:   pet1,
          pet2:   pet2, 
          date:   params[:datetime]
        })
      end
    end
  end

end
