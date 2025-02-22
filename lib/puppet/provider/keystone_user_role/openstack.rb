require File.join(File.dirname(__FILE__), '..','..','..', 'puppet/provider/keystone')
require File.join(File.dirname(__FILE__), '..','..','..', 'puppet_x/keystone/composite_namevar')

Puppet::Type.type(:keystone_user_role).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do
  desc "Provider to manage keystone role assignments to users."

  include PuppetX::Keystone::CompositeNamevar::Helpers

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.do_not_manage
    @do_not_manage
  end

  def self.do_not_manage=(value)
    @do_not_manage = value
  end

  def create
    if resource[:roles]
      options = properties
      resource[:roles].each do |role|
        self.class.system_request('role', 'add', [role] + options)
      end
    end
  end

  def destroy
    if @property_hash[:roles]
      options = properties
      @property_hash[:roles].each do |role|
        self.class.system_request('role', 'remove', [role] + options)
      end
    end
    @property_hash[:ensure] = :absent
  end

  def exists?
    roles_db = self.class.system_request('role assignment', 'list', ['--names'] + properties)
    if roles_db.empty?
      @property_hash[:ensure] = :absent
    else
      @property_hash[:ensure] = :present
      @property_hash[:roles]  = roles_db.collect do |role|
        role[:role]
      end
    end
    return @property_hash[:ensure] == :present
  end

  mk_resource_methods

  # Don't want :absent
  [:user, :user_domain, :project, :project_domain, :domain, :system].each do |attr|
    define_method(attr) do
      @property_hash[attr] ||= resource[attr]
    end
  end

  def roles=(value)
    current_roles = roles
    # determine the roles to be added and removed
    remove = current_roles - Array(value)
    add    = Array(value) - current_roles
    add.each do |role_name|
      self.class.system_request('role', 'add', [role_name] + properties)
    end
    remove.each do |role_name|
      self.class.system_request('role', 'remove', [role_name] + properties)
    end
  end

  private

  def properties
    return @properties if @properties
    properties = []
    if set?(:project)
      properties << '--project' << project
      properties << '--project-domain' << project_domain
    elsif set?(:domain)
      properties << '--domain' << domain
    else
      properties << '--system' << system
    end
    properties << '--user' << user
    properties << '--user-domain' << user_domain
    @properties = properties
  end
end
