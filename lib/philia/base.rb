module Philia
  module Base
    def self.included(base)
      base.extend ClassMethods
    end

    # #############################################################################
    # #############################################################################
    module ClassMethods
      # ------------------------------------------------------------------------
      # acts_as_tenant -- makes a tenanted model
      # Forces all references to be limited to current_tenant rows
      # ------------------------------------------------------------------------
      def acts_as_tenant
        belongs_to :tenant
        
        validates_presence_of :tenant_id

        default_scope -> { where("#{table_name}.tenant_id = ?", Thread.current[:tenant_id]) }

        # ..........................callback enforcers............................
        after_initialize do |obj|
          # Whenever we initialize a new object it needs to have the correct tenant_id of the current_user.
          # Ensures that destroy can be called on tenanted records which haven't been persisted yet.
          obj.tenant_id ||= Thread.current[:tenant_id]
        end

        # ..........................callback enforcers............................
        before_save do |obj| # force tenant_id to be correct for current_user
          # raise exception if updates attempted on wrong data
          raise ::Philia::Control::InvalidTenantAccess unless obj.tenant_id == Thread.current[:tenant_id]
        end

        # ..........................callback enforcers............................
        before_destroy do |obj| # force tenant_id to be correct for current_user
          raise ::Philia::Control::InvalidTenantAccess if obj.tenant_id != Thread.current[:tenant_id]
        end
      end

      # ------------------------------------------------------------------------
      # acts_as_universal -- makes a univeral (non-tenanted) model
      # Forces all reference to the universal tenant (nil)
      # ------------------------------------------------------------------------
      def acts_as_universal
        
        default_scope { where("#{table_name}.tenant_id IS NULL") }
        
        # ..........................callback enforcers............................
        before_save do |obj| # force tenant_id to be universal
          raise ::Philia::Control::InvalidTenantAccess if obj.tenant_id.present?
        end
        
        # ..........................callback enforcers............................
        before_destroy do |obj| # force tenant_id to be universal
          raise ::Philia::Control::InvalidTenantAccess unless obj.tenant_id.nil?
        end
      end
      
      # ------------------------------------------------------------------------
      # acts_as_universal_and_determines_tenant_reference
      # All the characteristics of acts_as_universal AND also does the magic
      # of binding a user to a tenant
      # ------------------------------------------------------------------------
      def acts_as_universal_and_determines_account
        include ::Philia::InviteMember
        has_and_belongs_to_many :tenants

        acts_as_universal

        # validate that a tenant exists prior to a user creation
        before_create do |_new_user|
          if Thread.current[:tenant_id].blank? ||
             !Thread.current[:tenant_id].is_a?(Integer) ||
             Thread.current[:tenant_id].zero?

            raise ::Philia::Control::InvalidTenantAccess, 'no existing valid current tenant'

          end
        end

        # before create, tie user with current tenant
        after_create do |new_user|
          tenant = Tenant.find(Thread.current[:tenant_id])
          unless tenant.users.include?(new_user)
            new_user.skip_reconfirmation! # For details why this is needed see philia issue #68
            tenant.users << new_user # add user to this tenant if not already there
          end
        end

        before_destroy do |old_user|
          old_user.tenants.clear # remove all tenants for this user
        end
      end

      # ------------------------------------------------------------------------
      # ------------------------------------------------------------------------
      def acts_as_universal_and_determines_tenant
        has_and_belongs_to_many :users

        # acts_as_universal

        before_destroy do |old_tenant|
          old_tenant.users.clear # remove all users from this tenant
          true
        end
      end

      # ------------------------------------------------------------------------
      # current_tenant -- returns tenant obj for current tenant
      # return nil if no current tenant defined
      # ------------------------------------------------------------------------
      def current_tenant
        (
        if Thread.current[:tenant_id].blank?
          nil
        else
          Tenant.find(Thread.current[:tenant_id])
        end
      )
      rescue ActiveRecord::RecordNotFound
        nil
      end

      # ------------------------------------------------------------------------
      # current_tenant_id -- returns tenant_id for current tenant
      # ------------------------------------------------------------------------
      def current_tenant_id
        Thread.current[:tenant_id]
      end

      # ------------------------------------------------------------------------
      # set_current_tenant -- model-level ability to set the current tenant
      # NOTE: *USE WITH CAUTION* normally this should *NEVER* be done from
      # the models ... it's only useful and safe WHEN performed at the start
      # of a background job (DelayedJob#perform)
      # ------------------------------------------------------------------------
      def set_current_tenant(tenant)
        # able to handle tenant obj or tenant_id
        case tenant
        when Tenant
          tenant_id = tenant.id
        when Integer
          tenant_id = tenant
        else
          raise ArgumentError, 'invalid tenant object or id'
        end

        old_id                     = (Thread.current[:tenant_id].nil? ? '%' : Thread.current[:tenant_id])
        Thread.current[:tenant_id] = tenant_id
        logger.debug("PHILIA >>>>> [Tenant#change_tenant] new: #{tenant_id}\told:#{old_id}") unless logger.nil?
      end

      # ------------------------------------------------------------------------
      # ------------------------------------------------------------------------

      # ------------------------------------------------------------------------
      # where_restrict_tenant -- gens tenant restrictive where clause for each klass
      # NOTE: subordinate join tables will not get the default scope by Rails
      # theoretically, the default scope on the master table alone should be sufficient
      # in restricting answers to the current_tenant alone .. HOWEVER, it doesn't feel
      # right. adding an additional .where( where_restrict_tenants(klass1, klass2,...))
      # for each of the subordinate models in the join seems like a nice safety issue.
      # ------------------------------------------------------------------------
      def where_restrict_tenant(*args)
        args.map { |klass| "#{klass.table_name}.tenant_id = #{Thread.current[:tenant_id]}" }.join(' AND ')
      end

      # ------------------------------------------------------------------------
      # ------------------------------------------------------------------------
    end
    # #############################################################################
    # #############################################################################
  end
end
