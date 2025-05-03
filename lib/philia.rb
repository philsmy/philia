# philia/lib/philia.rb

require "devise"
require "philia/engine" if defined?(Rails)

module Philia
  # Explicitly require Philia components instead of using autoload to avoid conflicts
  require "philia/version"
  require "philia/base"
  require "philia/control"
  require "philia/invite_member"

  # Configuration settings with default values
  mattr_accessor :use_coupon
  self.use_coupon = true

  mattr_accessor :use_recaptcha
  self.use_recaptcha = false

  mattr_accessor :signout_to_root
  self.signout_to_root = true

  mattr_accessor :use_airbrake
  self.use_airbrake = false

  mattr_accessor :use_invite_member
  self.use_invite_member = true

  mattr_accessor :trace_on
  self.trace_on = false

  # Whitelist tenant parameters, allowing expansion by the application
  @@whitelist_tenant_params = []

  def self.whitelist_tenant_params=(list)
    raise ArgumentError, "Expected an array of symbols" unless list.is_a?(Array)

    @@whitelist_tenant_params = list
  end

  def self.whitelist_tenant_params
    @@whitelist_tenant_params + [:name]
  end

  # Whitelist coupon parameters, allowing expansion by the application
  @@whitelist_coupon_params = []

  def self.whitelist_coupon_params=(list)
    raise ArgumentError, "Expected an array of symbols" unless list.is_a?(Array)

    @@whitelist_coupon_params = list
  end

  def self.whitelist_coupon_params
    @@whitelist_coupon_params + [:coupon]
  end

  # Method for setting up Philia with a block
  def self.setup
    yield self
  end
end

# Extend ActiveRecord with Philia::Base::ClassMethods if the module exists
ActiveSupport.on_load(:active_record) do
  extend Philia::Base::ClassMethods if defined?(Philia::Base::ClassMethods)
end

# Extend ActionController with Philia::Control if the module exists
ActiveSupport.on_load(:action_controller_base) do
  include Philia::Control if defined?(Philia::Control)
end
