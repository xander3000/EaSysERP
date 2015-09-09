class Payroll::ProcessRegularPayroll < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end

		attr_accessor :paid_employees,:paid_total

	humanize_attributes :payroll_payroll_type => "Tipo Nomina",
											:init_date => "Feha inicio",
											:end_date => "Fecha fin",
											:fortnight => "Quincena",
											:process_date => "Fecha proceso",
											:user => "Usuario",
											:paid => "¿Pagada?",
											:test => "Modo prueba",
											:id => "Nomina",
											:year => "Año",
											:month => "Mes",
											:paid_employees => "Abonados",
											:paid_total => "Total pagado"

	belongs_to :payroll_payroll_type,:class_name => "Payroll::PayrollType"
	belongs_to :user
	belongs_to :paid_by,:class_name => "User"
	has_many :payroll_regular_payroll_checks,:class_name => "Payroll::RegularPayrollCheck",:foreign_key => "payroll_process_regular_payroll_id",:order => "payroll_personal_type_id ASC"

	validates_presence_of :payroll_payroll_type,:init_date,:end_date,:fortnight,:process_date,:user
	before_save		:set_default_values

	named_scope :all_paid, lambda { |tag_name|  { :conditions => {:paid => true}  }}

#
  # Nombre
  #
  def name
    "#{month.to_code('2')}/#{year} (#{fortnight}º Quincena)"
  end

	#
	# Total pagado
	#
	def paid_total
		allocations = 0
		deductions = 0
		payroll_regular_payroll_checks.each do |payroll_regular_payroll_check|
			allocations += payroll_regular_payroll_check.total_amount_allocation
			deductions += payroll_regular_payroll_check.total_amount_deduction
		end
		allocations - deductions
	end

	#
	# Empleados pagados
	#
	def paid_employees
		total = 0
		payroll_regular_payroll_checks.each do |payroll_regular_payroll_check|
			total += payroll_regular_payroll_check.total_employees_paid
		end
		total
	end

  #
  # Conceptos nomina
  #
  def concepts_by_last_payrolls
		allocations = []
		deductions = []

		payroll_regular_payroll_checks.each do |payroll_regular_payroll_check|
			allocations.concat(payroll_regular_payroll_check.payroll_last_payrolls.all(:conditions => ["payroll_concepts.tag_name NOT IN (?) AND is_allocation = ?",Payroll::Concept.all_basic,true],:joins => [:payroll_concept_personal_type => :payroll_concept]).map(&:payroll_concept_personal_type).uniq)
			deductions.concat(payroll_regular_payroll_check.payroll_last_payrolls.all(:conditions => ["payroll_concepts.tag_name NOT IN (?) AND is_allocation = ?",Payroll::Concept.all_basic,false],:joins => [:payroll_concept_personal_type => :payroll_concept]).map(&:payroll_concept_personal_type).uniq)
		end
    {:allocations => allocations.uniq,:deductions => deductions.uniq}
  end

	#
	# Todos las nomina procedas por periodo
	#
	def self.all_group_by_period
		#all(:select => "year, month,payroll_personal_type_id",:conditions => {:paid => true},:group => "year, month,payroll_personal_type_id")
	end

	#
	# busca la siguiente nomian a prtir de hoy
	#
	def self.next_payroll(payroll_payroll_type,to_string=false)
		time_next_payroll,init_date,end_date,fortnight = date_next_payroll

		result = {:payroll_payroll_type_id => payroll_payroll_type.id,:init_date => init_date, :end_date => end_date,:fortnight => fortnight}

		next_payroll_by_personal_type = first(:conditions => result,:order => "id DESC")
		if next_payroll_by_personal_type and !next_payroll_by_personal_type[:test]
			paid = true
		else
			paid = false
		end
		result[:paid] = paid
		result[:process_date] = Time.now.strftime("%d/%m/%Y")

		result
	end

	#
	# Obtiene le periodp de la siguiente nomina
	#
	def self.date_next_payroll
		time_next_payroll = Time.now

		if time_next_payroll.day <= 15
			init_date = "01/#{Time.now.month.to_code("02")}/#{Time.now.year}"
			end_date = "15/#{Time.now.month.to_code("02")}/#{Time.now.year}"
			fortnight = 1
		else
			init_date = "16/#{Time.now.month.to_code("02")}/#{Time.now.year}"
			end_date = "#{Date.civil(Time.now.year, Time.now.month, -1).day}/#{Time.now.month.to_code("02")}/#{Time.now.year}"
			fortnight = 2
		end
		return time_next_payroll,init_date,end_date,fortnight
	end

  	#
	# Obtiene le periodp de la siguiente nomina
	#
	def date_payroll
		return created_at,init_date,end_date,fortnight
	end

	#
	# Si existe
	#
	def exist?
		self.class.first(:conditions => {:init_date => init_date, :end_date => end_date,:fortnight => fortnight,:payroll_payroll_type_id => payroll_payroll_type_id})
	end

	#
	# Pagar definitivo
	#
	def definitely_pay(paid_by)
		update_attributes(:test => false,:paid => true,:paid_by_id => paid_by.id)
			payroll_regular_payroll_checks.each do |payroll_regular_payroll_check|
					payroll_regular_payroll_check.payroll_last_payrolls.each do |last_payroll|
						attributes_c = last_payroll.attributes
						attributes_c.delete("id")
						attributes_c.delete("created_at")
						attributes_c.delete("updated_at")
						attributes_c["year"] = Time.now.year
						attributes_c["month"] = Time.now.month.to_code("02")
						historical_payroll = Payroll::HistoricalPayroll.new(attributes_c)
						if historical_payroll.valid?
							historical_payroll.save
						end
					end
			payment_frequencies = Payroll::LastPayroll.payment_frequencies_by_regular_payroll_check(payroll_regular_payroll_check)
			payroll_regular_payroll_check.payroll_personal_type.active_payroll_employees.all.each do |employee|
				employee.payroll_variable_concepts.all(:conditions => ["payroll_payment_frequency_id IN (?)",payment_frequencies]).each do |variable_concept|
					variable_concept.destroy
				end
			end
		end
	end

	#
	# Empleados procesados en la noina
	#
	def payroll_employess
		payroll_regular_payroll_checks.map(&:payroll_last_payrolls).flatten.map(&:payroll_employee).uniq
	end
	#
	# Obtiene la payroll_regular_payroll_check aociado a un empleado
	#
	def payroll_regular_payroll_check_for_employee(employee)
		Payroll::RegularPayrollCheck.first(:conditions => ["payroll_last_payrolls.payroll_employee_id = ? AND payroll_last_payrolls.payroll_regular_payroll_check_id IN (?)",employee.id,payroll_regular_payroll_checks.map(&:id)],:joins => [:payroll_last_payrolls])
	end

	#
	# Envia al empleado su recibo de pago asociado al objeto
	#
	def send_payment_receipt_by_mail(employee,file_path)

	end

	#
	# Monto base por conceptp y empleado
	#
	def base_amount_by_concept_and_employee(concept_code,employee)
		
	end

	#
	# Setea los valores por defecto
	#
	def set_default_values
		self.month = init_date.split("/")[1]
		self.year = init_date.split("/")[2]
		if !self.test
			self.paid = true
		end
	end


	#
	# es segunda nomina
	#
	def is_second_fortnight?
		fortnight.eql?(2)
	end




	#
	# Enviar recibos por correo a cada trabajador
	#
		def self.send_masive_payment_receipt_by_mail(id,file_prefix,file_path)

	end

	#
	# Busqueda de resumen de nomina
	#
	def self.find_resumen_concept_personal_type(options={})

	end

	def add_regular_payroll_check

			payroll_payroll_type.payroll_type_personal_types.each do |payroll_type_personal_type|
						attributes_regular_payroll_check = attributes
						attributes_regular_payroll_check.delete("id")
						attributes_regular_payroll_check.delete("payroll_payroll_type_id")
						attributes_regular_payroll_check.delete("created_at")
						attributes_regular_payroll_check.delete("updated_at")
						attributes_regular_payroll_check["payroll_personal_type_id"] = payroll_type_personal_type.id

						payroll_regular_payroll_check = Payroll::RegularPayrollCheck.new(attributes_regular_payroll_check)
						exist_value = payroll_regular_payroll_check.exist?
				
					if exist_value
						payroll_regular_payroll_check = exist_value
					else
						payroll_regular_payroll_check.user = user
					end
				
						payroll_regular_payroll_check.test = true
						success = payroll_regular_payroll_check.valid?
					if success
						payroll_regular_payroll_check.save
						payroll_regular_payroll_check.reload
						Payroll::LastPayroll.massive_process(payroll_regular_payroll_check)
						allocations = payroll_regular_payroll_check.payroll_last_payrolls.sum("amount_allocated")
						deductions = payroll_regular_payroll_check.payroll_last_payrolls.sum("amount_deducted")

						payroll_regular_payroll_check.update_attributes(:payroll_process_regular_payroll_id => id,
																														:total_employees_paid => payroll_regular_payroll_check.paid_employees.size,
																														:total_amount_allocation => allocations,
																														:total_amount_deduction => deductions,
																														:total_amount_paid => allocations - deductions)
					end
		end
	end
end
