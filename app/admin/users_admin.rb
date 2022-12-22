Trestle.resource(:users) do
  menu do
    item :admins, icon: "fa fa-user"
  end

  scopes do
    scope :admins, default: true
  end

  table do
    column :id
    column :email 
    column :created_at 
    column :updated_at
    column :admin
    actions 
  end
  # Customize the table columns shown on the index view.
  #

  # Customize the form fields shown on the new/edit views.
  #
  # form do |user|
  #   text_field :name
  #
  #   row do
  #     col(xs: 6) { datetime_field :updated_at }
  #     col(xs: 6) { datetime_field :created_at }
  #   end
  # end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:user).permit(:name, ...)
  # end
end
