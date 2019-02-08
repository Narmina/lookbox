module External

  class ApiVersion1 < Grape::API
    prefix 'api'
    version 'v1', :using => :path
    format :json

    before do
      error!("401 Unauthorized, 401") unless authenticated
    end

    helpers do
      def warden
        env['warden']
      end

      def authenticated
        return true if warden.authenticated?
        params[:access_token] && @user = User.find_by_access_token(params[:access_token])
      end

      def current_user
        warden.try(:user) || @user
      end
    end

    desc "Return users list"
    get :users_list do
      users = User.all
      users.to_json(:only => [:id, :email, :name])
    end

    desc "Return pictures list"
    get :pictures_list do
      users = User.all
      users.to_json(:only => [:id, :email, :name])
    end
  end

end
