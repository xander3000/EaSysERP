class Crm::CallInvitee < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end
end
