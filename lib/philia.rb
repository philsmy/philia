begin
<<<<<<< HEAD
  require "rails/engine"
  require "philia/version"
  require "philia/password"
=======
  require 'rails/engine'
  require 'philia/version'
  require 'philia/engine'
  require 'philia/password'
>>>>>>> ruby3password
rescue LoadError
end

module Philia
  extend ActiveSupport::Autoload

  autoload :VERSION
  autoload :Base
  autoload :Control
  autoload :InviteMember

  # expecting params[:coupon] for sign-ups
  mattr_accessor :use_coupon
  @@use_coupon = true

  # use recaptcha to validate human params input
  mattr_accessor :use_recaptcha
  @@use_recaptcha = false

  # use sign_out to root; else return to sign-in page
  mattr_accessor :signout_to_root
  @@signout_to_root = true

  # use airbrake gem to log exceptions
  mattr_accessor :use_airbrake
  @@use_airbrake = false

  # use invite_member for devise work-around to invite members
  # ASSUMES User model
  mattr_accessor :use_invite_member
  @@use_invite_member = true

  # whitelist tenant params list
  # allows an app to expand the permitted attribute list
  # specify each attribute as a symbol
  # example: [:name]
  # config.whitelist_tenant_params = []
  @@whitelist_tenant_params = []

  def self.whitelist_tenant_params=(list)
    raise ArgumentError unless !list.nil? && list.is_a?(Array)

    @@whitelist_tenant_params = list
  end

  def self.whitelist_tenant_params
    @@whitelist_tenant_params << :name
  end

  # whitelist coupon params list
  # allows an app to expand the permitted attribute list
  # specify each attribute as a symbol
  # example: [:name]
  # config.whitelist_coupon_params = []
  @@whitelist_coupon_params = []

  def self.whitelist_coupon_params=(list)
    raise ArgumentError unless !list.nil? && list.is_a?(Array)

    @@whitelist_coupon_params = list
  end

  def self.whitelist_coupon_params
    @@whitelist_coupon_params << :coupon
  end

  # undocumented feature, debugging trace, default is off
  mattr_accessor :trace_on
  @@trace_on = false

  # Default way to setup philia.
  def self.setup
    yield self
  end
end

ActiveSupport.on_load(:active_record) do
  extend Philia::Base::ClassMethods
end
