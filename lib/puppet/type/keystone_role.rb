Puppet::Type.newtype(:keystone_role) do

  desc <<-EOT
    This is currently used to model the creation of
    keystone roles.
  EOT

  ensurable

  newparam(:name, :namevar => true) do
    newvalues(/\S+/)
  end

  newproperty(:id) do
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  # we should not do anything until the keystone service is started
  autorequire(:anchor) do
    ['keystone::service::end']
  end
end
