require 'csv'

Trestle.resource(:applications, scope: Remote) do
  menu do
    item :applications, icon: "fa fa-mobile"
  end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end
  table do
    column :id
    column :name 
    column :category 
    column :is_observed
    actions do |toolbar, instance, admin|
      # toolbar.edit if admin && admin.actions.include?(:edit)
      # toolbar.delete if admin && admin.actions.include?(:destroy)
      if instance.config["csv_export"]
        toolbar.link "Import CSV", admin.path(:import_csv, id: instance.id), class: 'btn btn-danger'
      end
    end
  end

  controller do
    def import_csv
      @app = admin.find_instance(params)
    end

    def parse_csv_and_import
      @app = admin.find_instance(params)
      file = params[:csv].tempfile
      @app.fetcher.parse_csv(file)

      flash[:alert] = "Import successful"
      redirect_to :remote_applications_admin_index
    end
  end

  routes do
    get :import_csv, on: :member
    post :parse_csv_and_import, on: :member
  end

  # Customize the form fields shown on the new/edit views.
  #
  # form do |remote_application|
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
  #   params.require(:remote_application).permit(:name, ...)
  # end
end
