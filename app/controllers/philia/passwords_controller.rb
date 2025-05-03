module Philia
  class PasswordsController < Devise::PasswordsController
    skip_before_action :authenticate_tenant!, only: %i[new create edit update]
  end
end
