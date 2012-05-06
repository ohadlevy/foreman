class Node::Provisioned::BareMetal < Node::Managed
  include Node::Provisioned::Common
  include Node::Provisioned::BuildCommon

  validates_uniqueness_of :ip
  validates_presence_of   :ip
  validates_format_of     :ip,  :with => Net::Validations::IP_REGEXP

  validates_uniqueness_of :mac
  validates_presence_of   :mac
  validates_format_of     :mac, :with => Net::Validations::MAC_REGEXP

  belongs_to :sp_subnet, :class_name => "Subnet"
  validates_uniqueness_of  :sp_mac, :allow_nil => true, :allow_blank => true
  validates_uniqueness_of  :sp_name, :sp_ip, :allow_blank => true, :allow_nil => true
  validates_format_of      :sp_mac,  :with => Net::Validations::MAC_REGEXP, :allow_nil => true, :allow_blank => true
  validates_format_of      :sp_ip,   :with => Net::Validations::IP_REGEXP, :allow_nil => true, :allow_blank => true
  validates_format_of      :serial,  :with => /[01],\d{3,}n\d/, :message => "should follow this format: 0,9600n8", :allow_blank => true, :allow_nil => true

  def self.model_name; Host.model_name; end

  def sp_valid?
    !sp_name.empty? and !sp_ip.empty? and !sp_mac.empty?
  end

end
