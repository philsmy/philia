require_dependency 'devise/passwords_controller'

class Philia::PasswordsController < Devise::PasswordsController
  skip_before_action :authenticate_tenant!, only: %i[new create edit update]
end
