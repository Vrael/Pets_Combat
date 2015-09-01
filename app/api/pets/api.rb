module Pets
  class API < Grape::API
    version 'v1', using: :header, vendor: 'groopify'
    format :json
    prefix :api

    before do
      error!("401 Unauthorized", 401) unless authenticated
    end

    helpers do
      def authenticated
        params[:access_token] && @user = User.find_by_authentication_token(params[:access_token])
      end

      def current_user
        @user
      end
    end

    resource :pets do

      desc "Create a pet."
      params do
        requires :name,   type: String,   desc: 'Pet\'s name'
        requires :age,    type: Integer,  desc: 'Pet\'s age'
        requires :gender, type: String,   values: ['male', 'female']
        requires :kind,   type: String,   values: ['rat', 'dog', 'chinchilla']
      end
      post do
        Pet.create!({
          user:   current_user,
          name:   params[:name],
          age:    params[:age],
          gender: params[:gender],
          kind:   params[:kind]
        })
      end
    end
  end
end
