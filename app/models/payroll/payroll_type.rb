class Payroll::PayrollType < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end
	humanize_attributes :name => "Nombre"

	has_many :payroll_type_personal_types,:class_name => "Payroll::PayrollTypePersonalType",:foreign_key => "payroll_payroll_type_id"


	#
  # tiene todas las obligaciones de ley
  #
  def has_all_deductions?
		result = true
		payroll_type_personal_types.each do |payroll_type_personal_type|
			payroll_personal_type = payroll_type_personal_type.payroll_personal_type
			result &= Payroll::ConceptPersonalType.all(:conditions => ["payroll_personal_type_id =  ? AND payroll_concepts.tag_name IN (?)",payroll_personal_type.id ,Payroll::Concept.all_deductions],:joins => [:payroll_concept]).size.eql?(Payroll::Concept.all_deductions.size)
		end
		result
  end


end
