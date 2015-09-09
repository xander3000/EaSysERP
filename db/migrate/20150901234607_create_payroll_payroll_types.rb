class CreatePayrollPayrollTypes < ActiveRecord::Migration
  def self.up
    create_table :payroll_payroll_types do |t|
			t.string :name, :null => false
    end
		Payroll::PayrollType.create(:name => "Empleados")
		Payroll::PayrollType.create(:name => "Directivos")
  end

  def self.down
    drop_table :payroll_payroll_types
  end
end
