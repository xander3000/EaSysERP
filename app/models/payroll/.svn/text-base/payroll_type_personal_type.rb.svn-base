class Payroll::PayrollTypePersonalType < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end

	belongs_to :payroll_payroll_type,:class_name => "Payroll::PayrollType"
	belongs_to :payroll_personal_type,:class_name => "Payroll::PersonalType"
end
