require_dependency 'devise/sessions_controller'

class Philia::SessionsController < Devise::SessionsController
  # skip need for authentication
  skip_before_action :authenticate_tenant!, only: %i[new create destroy]
  # clear tenanting
  before_action :__philia_reset_tenant!, only: %i[create destroy]
end
