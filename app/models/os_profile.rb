class OsProfile < ActiveRecord::Base
  belongs_to :architecture
  belongs_to :operatingsystem
  belongs_to :ptable

end
