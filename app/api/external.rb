module External

  class ApiVersion1 < Grape::API
    prefix 'api'
    version 'v1', :using => :path
    format :json

    before do
      error!("401 Unauthorized", 401) unless authenticated
    end

    helpers do
      def warden
        request.env['warden']
      end

      def authenticated
        return true if warden.present? && warden.authenticated?
        @user = User.find_user_by_access_token(params[:access_token])
        params[:access_token] && @user.present?
      end

      def current_user
        warden.try(:user) || @user
      end

      def record_not_found
        error!('Record not found', 404)
      end

    end

    desc "Return users list"
    get :users_list do
      users = User.all
      users.to_json(:only => [:id, :email, :name])
    end

    desc "Return pictures list"
    get :pictures_list do
      current_user.pictures.to_json(:only => [:id, :title, :description, :created_at, :updated_at])
    end

    desc "Return pictures list"
    get :categories_list do
      current_user.categories.to_json(:only => [:id, :title, :description, :created_at, :updated_at])
    end

    desc "Return pictures list"
    get :looks_list do
      current_user.looks.to_json(:only => [:id, :name, :description, :parent_id, :created_at, :updated_at])
    end


  end

end
