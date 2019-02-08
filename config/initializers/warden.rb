#Rails.application.config.middleware.insert_after ActionDispatch::Flash, Warden::Manager do |manager|
# Rails.application.config.middleware.use Warden::Manager do |manager|
#   manager.default_strategies :authentication_token
# end