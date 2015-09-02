class Pet < ActiveRecord::Base
   belongs_to :user

   has_many :combats
end
