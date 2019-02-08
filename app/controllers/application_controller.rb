class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include Error::ErrorHandler

  before_filter :store_location
  before_filter :authenticate_user!
  before_filter :set_default_per_page
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_locale

  def try_chain
    yield
  rescue NoMethodError
    nil
  end

  def after_sign_in_path_for(resource_or_scope)
    session[:previous_url] || root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :password, :current_password, :birth_date])
  end

  def path_not_found
    raise ActionController::RoutingError.new("No route matches #{params[:path]}")
  end

  private

  def set_default_per_page
    @kaminari_per_page = Kaminari.config.default_per_page
  end

  def set_locale
    I18n.locale = params[:locale] || try_chain { current_user.current_user_setting.locale.locale } || I18n.default_locale
  end

  def default_url_options(options = {})
    options.merge({locale: ((I18n.locale.to_s == try_chain { current_user.current_user_setting.locale.locale} ) ? nil : I18n.locale) })
  end

  def store_location
    return unless request.get?
    controllers = %w(home sessions passwords omniauth_callbacks)
    if (controllers.none? {|name| controller_name.include? name } && !request.xhr?)
      session[:previous_url] = request.fullpath
    end
  end

end
