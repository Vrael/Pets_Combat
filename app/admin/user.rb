ActiveAdmin.register User do
  permit_params :name, :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :current_sign_in_at
    column :created_at
    actions
  end

  filter :name
  filter :email
  filter :current_sign_in_at
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
