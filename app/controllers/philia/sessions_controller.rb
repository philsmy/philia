module Philia
  class SessionsController < Devise::SessionsController
    skip_before_action :authenticate_tenant!, only: %i[new create destroy]
    before_action :__philia_reset_tenant!, only: %i[create destroy]

    protected

    def after_sign_in_path_for(resource)
      session.delete(:return_to) || super
    end
  end
end
