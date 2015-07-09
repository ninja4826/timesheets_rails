class Month < ActiveRecord::Base
  has_many :sheets, :dependent => :destroy
end
