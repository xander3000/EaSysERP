class CreatePayrollProcessRegularPayrolls < ActiveRecord::Migration
  def self.up
    create_table :payroll_process_regular_payrolls do |t|
			t.integer			:year,:null => false
			t.integer			:month,:null => false
			t.string			:init_date,:null => false
			t.string			:end_date,:null => false
			t.integer			:fortnight,:null => false
			t.string			:process_date,:null => false
			t.references	:user,:null => false
			t.references	:paid_by
			t.references	:payroll_payroll_type,:null => false
			t.boolean			:paid,:default => false
			t.boolean			:test,:default => false
#			t.integer			:total_employees_paid,:default => 0
#			t.decimal			:total_amount_allocation,:precision => 20, :scale => 2,:default => 0
#			t.decimal			:total_amount_deduction,:precision => 20, :scale => 2,:default => 0
#			t.decimal			:total_amount,:precision => 20, :scale => 2,:default => 0
#			t.decimal			:total_amount_paid,:precision => 20, :scale => 2,:default => 0
      t.timestamps
    end
		add_column :payroll_regular_payroll_checks,:payroll_process_regular_payroll_id,:integer
		add_column :payroll_regular_payroll_checks,:total_employees_paid,:integer,:default => 0
		add_column :payroll_regular_payroll_checks,:total_amount_allocation,:decimal,:precision => 20, :scale => 2,:default => 0
		add_column :payroll_regular_payroll_checks,:total_amount_deduction,:decimal,:precision => 20, :scale => 2,:default => 0
		add_column :payroll_regular_payroll_checks,:total_amount_paid,:decimal,:precision => 20, :scale => 2,:default => 0

		processes = [{:year => 2015,:months => [1,2,3,4,5,6,7,8]}]
		processes.each do |process|
			year = process[:year]
			process[:months].each do |month|
				Payroll::PayrollType.all.each do |payroll_type|
					init_date = "01/#{month.to_code("02")}/#{year}"
					end_date = "15/#{month.to_code("02")}/#{year}"
					#1 fortnight
					Payroll::ProcessRegularPayroll.create(:year => year,:month => month,:init_date => init_date,
																								:end_date => end_date,:fortnight => 1,:process_date => end_date,
																								:user_id => 1,:paid_by_id => 1,:payroll_payroll_type_id => payroll_type.id,
																								:paid => true,:test => false
																							)
					#2 fortnight
					init_date = "15/#{month.to_code("02")}/#{year}"
					end_date = "#{Date.civil(year, month, -1).day}/#{month.to_code("02")}/#{year}"
					Payroll::ProcessRegularPayroll.create(:year => year,:month => month,:init_date => init_date,
																								:end_date => end_date,:fortnight => 2,:process_date => end_date,
																								:user_id => 1,:paid_by_id => 1,:payroll_payroll_type_id => payroll_type.id,
																								:paid => true,:test => false)
				end
			end
		end


		Payroll::RegularPayrollCheck.all.each do |regular_payroll_check|
			process_regular_payroll = Payroll::ProcessRegularPayroll.first(:conditions => ["year = ? AND month = ? AND fortnight = ?  AND payroll_payroll_type_personal_types.payroll_personal_type_id = ?",regular_payroll_check.year,regular_payroll_check.month,regular_payroll_check.fortnight,regular_payroll_check.payroll_personal_type.id],:joins => [:payroll_payroll_type=> [:payroll_type_personal_types]])

			regular_payroll_check.update_attribute(:payroll_process_regular_payroll_id, process_regular_payroll.id) if process_regular_payroll

			
					allocations = regular_payroll_check.payroll_last_payrolls.sum("amount_allocated")
					deductions = regular_payroll_check.payroll_last_payrolls.sum("amount_deducted")
					
					regular_payroll_check.update_attributes(:total_employees_paid => regular_payroll_check.paid_employees.size,
																									:total_amount_allocation => allocations,
																									:total_amount_deduction => deductions,
																									:total_amount_paid => allocations - deductions)
			
		end

  end

  def self.down
    drop_table :payroll_process_regular_payrolls
		remove_columns( :payroll_regular_payroll_checks,:payroll_process_regular_payroll_id,:total_employees_paid,:total_amount_allocation,:total_amount_deduction,:total_amount_paid)
  end
end
