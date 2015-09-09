class CreatePayrollPayrollTypePersonalTypes < ActiveRecord::Migration
  def self.up
    create_table :payroll_payroll_type_personal_types do |t|
			t.references	:payroll_payroll_type,:null => false
			t.references	:payroll_personal_type,:null => false
    end
		fijo = Payroll::PersonalType.find_by_tag_name("fijo")
		periodo_prueba = Payroll::PersonalType.find_by_tag_name("periodo_prueba")
		directivo = Payroll::PersonalType.find_by_tag_name("directivo")

		Payroll::PayrollTypePersonalType.create(:payroll_payroll_type_id =>1,:payroll_personal_type_id =>  fijo.id)
		Payroll::PayrollTypePersonalType.create(:payroll_payroll_type_id => 1,:payroll_personal_type_id => periodo_prueba.id)
		Payroll::PayrollTypePersonalType.create(:payroll_payroll_type_id => 2,:payroll_personal_type_id => directivo.id)
  end

  def self.down
    drop_table :payroll_payroll_type_personal_types
  end
end
