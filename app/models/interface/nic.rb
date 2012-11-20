class NIC < Interface
  validates_uniqueness_of :name, :scope => :domain_id
end
