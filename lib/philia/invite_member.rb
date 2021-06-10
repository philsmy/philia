module Philia
  module InviteMember
    # #############################################################################

    def self.included(base)
      base.extend ClassMethods
    end

    # #############################################################################
    # #############################################################################
    module ClassMethods
    end
    # #############################################################################
    # #############################################################################

    # ------------------------------------------------------------------------
    # new function to set the password without knowing the current password
    # ------------------------------------------------------------------------
    def attempt_set_password(params)
      p = {}
      p[:password] = params[:password]
      p[:password_confirmation] = params[:password_confirmation]
      update_attributes(p)
    end

    # ------------------------------------------------------------------------
    # new function to return whether a password has been set
    # ------------------------------------------------------------------------
    def has_no_password?
      encrypted_password.blank?
    end

    # ------------------------------------------------------------------------
    # new function to provide access to protected method unless_confirmed
    # ------------------------------------------------------------------------
    def only_if_unconfirmed
      pending_any_confirmation { yield }
    end

    # ------------------------------------------------------------------------
    # ------------------------------------------------------------------------

    # ------------------------------------------------------------------------
    # save_and_invite_member -- saves the new user record thus inviting member
    # via devise
    # if password missing; gens a password
    # ensures email exists and that email is unique and not already in system
    # ------------------------------------------------------------------------
    def save_and_invite_member
      status = nil

      if email.blank?
        errors.add(:email, :blank)
      elsif User.where(['lower(email) = ?', email.downcase]).present?
        errors.add(:email, :taken)
      else
        check_or_set_password
        status = save && errors.empty?
      end

      status
    end

    # ------------------------------------------------------------------------
    # check_or_set_password -- if password missing, generates a password
    # ASSUMES: Philia.use_invite_member
    # ------------------------------------------------------------------------
    def check_or_set_password
      if password.blank?
        self.password =
          ::Philia::Password.generate(
            8, Password::ONE_DIGIT | Password::ONE_CASE
          )

        self.password_confirmation = password
      elsif ::Philia.use_invite_member
        self.skip_confirm_change_password = true
      end
      # if a password is being supplied, then ok to skip
      # setting up a password upon confirm
    end

    # #############################################################################
  end

  # #############################################################################
end
