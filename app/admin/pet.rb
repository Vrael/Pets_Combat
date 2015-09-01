ActiveAdmin.register Pet do

  index do
    selectable_column
    id_column
    column :name
    column :age
    column :gender
    column :type
    column :rate
    column :created_at
    actions
  end

end
