class Combat < ActiveRecord::Base
  belongs_to :pet1, class_name: 'Pet'
  belongs_to :pet2, class_name: 'Pet'
  belongs_to :winner, class_name: 'Pet'
end
