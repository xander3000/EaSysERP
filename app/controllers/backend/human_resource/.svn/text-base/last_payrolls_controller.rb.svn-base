class Backend::HumanResource::LastPayrollsController < Backend::HumanResource::BaseController

	def index
		@title = "Recursos Humanos / Nomina ordinaria procesadas"
		@process_regular_payrolls = Payroll::ProcessRegularPayroll.all_paid
	end

	def new

	end

	def new_massive_process
			@title = "Recursos Humanos / Generar nomina ordinaria "
			@process_regular_payroll = Payroll::ProcessRegularPayroll.new
	end

	def search_next_payroll_by_payroll_type
		@errors = {}
		@payroll_payroll_type = Payroll::PayrollType.find_by_id(params[:payroll_process_regular_payroll][:payroll_payroll_type_id])
		result = Payroll::ProcessRegularPayroll.next_payroll(@payroll_payroll_type) if @payroll_payroll_type
		@process_regular_payroll = Payroll::ProcessRegularPayroll.new(result)
		@process_regular_payroll.test = true
		@success = true

		if @process_regular_payroll and @process_regular_payroll.paid
			@success = false
			@errors[Payroll::ProcessRegularPayroll.human_attribute_name("id").to_s] = "ya fue procesada"
		end
    if @payroll_payroll_type.nil?
			@success = false
			@errors[Payroll::ProcessRegularPayroll.human_attribute_name("id").to_s] = "no fue posible cargar la nomina"
		end
		if !@payroll_payroll_type.nil? and !@payroll_payroll_type.has_all_deductions?
			@success = false
			@errors[Payroll::ProcessRegularPayroll.human_attribute_name("id").to_s] = "no fue posible cargar la nomina, deduciones de ley no registradas"
		end
		if @success and @process_regular_payroll.test
			flash[:warning] = "Se esta ejecutando en el proceso de prenomina."
		end
	end

	def create_massive_process
		@process_regular_payroll = Payroll::ProcessRegularPayroll.new(params[:payroll_process_regular_payroll])


		exist = @process_regular_payroll.exist?

		if exist
			@process_regular_payroll = exist
		else
			@process_regular_payroll.user = current_user
		end

		@process_regular_payroll.test = true
		@success = @process_regular_payroll.valid?
		if @success
			@process_regular_payroll.save
			@process_regular_payroll.reload
			@process_regular_payroll.add_regular_payroll_check
			flash[:notice] = "Su prenomina ha sido procesada exitosamente!!"
		end
	end

	def show_massive_process
		@title = "Recursos Humanos / Nomina ordinaria "
		@process_regular_payroll = Payroll::ProcessRegularPayroll.find(params[:process_regular_payroll_id])
    @concepts_by_last_payrolls = @process_regular_payroll.concepts_by_last_payrolls
		respond_to do |format|
      format.html
      format.pdf do
        @title = "<b>PROCESO DE NOMINA #{@process_regular_payroll.name.upcase} Nº #{@process_regular_payroll.id.to_code}   </b> <br/>
                  Periodo  #{@process_regular_payroll.init_date} al #{@process_regular_payroll.end_date}"
				render :pdf                            => "#{@process_regular_payroll.name.to_underscore.upcase}_#{@process_regular_payroll.month}_#{@process_regular_payroll.year}(#{@process_regular_payroll.fortnight})",
               :disposition                    => 'attachment',
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_height => '20in',
							 :page_width => '15in',
							 :orientation										 => 'Landscape',
               :template                       => "#{@current_controller}/show_resume_massive_process",
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '2'
														},
							 :margin => {:top                => 26,
                           :bottom             => 20,
													 :right              => 2,
                           :left               => 5
 												 }
        end
      format.csv do
          path_to_save = "#{RAILS_ROOT}/public/csv"
          file_name = "#{path_to_save}/#{@process_regular_payroll.payroll_payroll_type.name.to_underscore.upcase}_#{@process_regular_payroll.month}_#{@process_regular_payroll.year}(#{@process_regular_payroll.fortnight}).csv"
          if !File.exist?(path_to_save)
            system 'mkdir', '-p', path_to_save
          end
          	 owner = Supplier.find_owner
              contact = owner.contact
              CSV.open(file_name, "wb",  ';' ) do |csv|
                          csv << [Iconv.iconv('iso8859-1','utf-8', contact.fullname.upcase).first]
                          csv << []
                          header = [Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("fullname")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Staff.human_attribute_name("identification_document")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("payroll_position")).first,
																		Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("payroll_personal_type")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("income_date")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("integral_salary")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("salary_fortnight")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("salary_daily")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("account_number")).first
                                    ]
                                    @concepts_by_last_payrolls[:allocations].each do |concepts_by_last_payroll|
                                      header << Iconv.iconv('iso8859-1','utf-8', concepts_by_last_payroll.payroll_concept.name.capitalize).first
                                    end

                                    header.concat([Iconv.iconv('iso8859-1','utf-8', Payroll::LastPayroll.human_attribute_name("amount_allocations")).first,
                                    Iconv.iconv('iso8859-1','utf-8', "SSO").first,
                                    Iconv.iconv('iso8859-1','utf-8', "SPF").first,
                                    Iconv.iconv('iso8859-1','utf-8', "FAOV").first,
                                    Iconv.iconv('iso8859-1','utf-8', "ISLR").first
                                    ])
                                    @concepts_by_last_payrolls[:deductions].each do |concepts_by_last_payroll_deduction|
                                      header << Iconv.iconv('iso8859-1','utf-8', concepts_by_last_payroll_deduction.payroll_concept.name.capitalize).first
                                    end
                                   
                                    header << Iconv.iconv('iso8859-1','utf-8', Payroll::LastPayroll.human_attribute_name("amount_deductions")).first
                                    header << Iconv.iconv('iso8859-1','utf-8', Payroll::LastPayroll.human_attribute_name("total_amount")).first
                               csv << header.map(&:upcase)
												 @process_regular_payroll.payroll_regular_payroll_checks.each do |payroll_regular_payroll_check|
                          payroll_regular_payroll_check.paid_employees.each do |employee|
                            totals = employee.totals_payroll_by_regular_payroll_check(payroll_regular_payroll_check)
                            concepts_payroll_by_regular_payroll_check = employee.concepts_payroll_by_regular_payroll_check(payroll_regular_payroll_check)
                            salary = Payroll::LastPayroll.base_amount_by_concept(payroll_regular_payroll_check,employee,Payroll::Concept.basic_salary)

                            row = [
                                    Iconv.iconv('iso8859-1','utf-8', employee.fullname).first,
                                    Iconv.iconv('iso8859-1','utf-8', employee.identification_document).first,
                                    Iconv.iconv('iso8859-1','utf-8', employee.payroll_position.name).first,
																		Iconv.iconv('iso8859-1','utf-8', employee.payroll_personal_type.name).first,
                                    Iconv.iconv('iso8859-1','utf-8', employee.income_date).first,
                                    Iconv.iconv('iso8859-1','utf-8', salary.to_f.to_currency(false).to_s).first,
                                    Iconv.iconv('iso8859-1','utf-8', (salary/2).to_f.to_currency(false).to_s).first,
                                    Iconv.iconv('iso8859-1','utf-8', employee.salary_for_day.to_currency(false).to_s).first,
                                    Iconv.iconv('iso8859-1','utf-8', employee.account_number).first
                                    ]
                                    @concepts_by_last_payrolls[:allocations].each do |concepts_by_last_payroll|
                                      row << Iconv.iconv('iso8859-1','utf-8', concepts_payroll_by_regular_payroll_check[concepts_by_last_payroll.payroll_concept.tag_name.to_sym].to_f.abs.to_currency(false).to_s).first
                                    end
                                    row.concat([Iconv.iconv('iso8859-1','utf-8', totals[:amount_allocations].to_currency(false).to_s).first,
                                    Iconv.iconv('iso8859-1','utf-8', concepts_payroll_by_regular_payroll_check[Payroll::Concept::SSO.to_sym].to_f.abs.to_currency(false).to_s).first,
                                    Iconv.iconv('iso8859-1','utf-8', concepts_payroll_by_regular_payroll_check[Payroll::Concept::SPF.to_sym].to_f.abs.to_currency(false).to_s).first,
                                    Iconv.iconv('iso8859-1','utf-8', concepts_payroll_by_regular_payroll_check[Payroll::Concept::FAOV.to_sym].to_f.abs.to_currency(false).to_s).first,
                                    Iconv.iconv('iso8859-1','utf-8', concepts_payroll_by_regular_payroll_check[Payroll::Concept::ISLR.to_sym].to_f.abs.to_currency(false).to_s).first
                                    ])
                                  @concepts_by_last_payrolls[:deductions].each do |concepts_by_last_payroll_deduction|
                                    row << Iconv.iconv('iso8859-1','utf-8', concepts_payroll_by_regular_payroll_check[concepts_by_last_payroll_deduction.payroll_concept.tag_name.to_sym].to_f.abs.to_currency(false).to_s).first
                                  end
                                  
                                  row << Iconv.iconv('iso8859-1','utf-8', totals[:amount_deductions].to_currency(false).to_s).first
                                  row << Iconv.iconv('iso8859-1','utf-8', totals[:total_amount].to_currency(false).to_s).first
                              csv << row
                          end
											 end
                    end
          send_file file_name,:type => "text/csv;"




      end
			format.txt do
				if !File.exist?("#{RAILS_ROOT}/public/txt")
					system 'mkdir', '-p', "#{RAILS_ROOT}/public/txt"
				end
					file_name = "#{RAILS_ROOT}/public/txt/#{AppConfig.faov_account}#{@payroll_regular_payroll_check.month.to_code("02")}#{@payroll_regular_payroll_check.year}.txt"
					out_file = File.new(file_name, "w")
          current_period = "#{@payroll_regular_payroll_check.year}#{@payroll_regular_payroll_check.month}"
					 Payroll::LastPayroll.paid_employees(@payroll_regular_payroll_check.month,@payroll_regular_payroll_check.year).each do |employee|
						 if employee.faov_listed
							 payroll_staff = employee.payroll_staff
							 y,m,d = employee.income_date.split("-")
							 income_date = "#{d}#{m}#{y}"
               y,m,d = employee.discharge_date.nil? ? ["","",""] : employee.discharge_date.split("-")
               discharge_date = "#{d}#{m}#{y}"
							                               
							 amount_base = 0
							 employee.all_payroll_payables_by_month_year(@payroll_regular_payroll_check.month,@payroll_regular_payroll_check.year).each do |payroll_regular_payroll_check|
                  base_amount_by_concept_and_employee = payroll_regular_payroll_check.base_amount_by_concept_and_employee(Payroll::Concept::FAOV,employee)
                  amount_base += base_amount_by_concept_and_employee.amount_base if base_amount_by_concept_and_employee
							end
              out_file.puts("#{employee.nationality},#{employee.only_identification_document},#{payroll_staff.first_name},#{payroll_staff.second_name},#{payroll_staff.last_name},#{payroll_staff.second_last_name},#{amount_base.to_f.to_currency_without_separators},#{income_date},#{discharge_date}".upcase) if !amount_base.zero?
					 end
					 end
					 out_file.close
					send_file file_name
			end
			format.xml do
					if !File.exist?("#{RAILS_ROOT}/public/xml")
						system 'mkdir', '-p', "#{RAILS_ROOT}/public/xml"
					end
					file_name = "#{RAILS_ROOT}/public/xml/#{COMPANY_IDENTIFICATION_DOCUMENT}#{@payroll_regular_payroll_check.month.to_code("02")}#{@payroll_regular_payroll_check.year}.xml"
					out_file = File.new(file_name, "w")



				  xml = Builder::XmlMarkup.new( :indent => 2, :target => out_file )
					xml.instruct! :xml, :encoding => "ISO-8859-1"
					xml.RelacionRetencionesISLR :RifAgente => COMPANY_IDENTIFICATION_DOCUMENT.gsub(/[\/-]/,''), :Periodo=> "#{@payroll_regular_payroll_check.year}#{@payroll_regular_payroll_check.month.to_code("02")}" do |ri|
						@payroll_regular_payroll_check.paid_employees.each do |employee|
							payroll_staff = employee.payroll_staff
							ri.DetalleRetencion  do |dr|
									dr.RifRetenido payroll_staff.rif.gsub(/[\/-]/,'')
									dr.NumeroFactura "000"
									dr.NumeroControl "000"
									dr.FechaOperacion "#{Time.now.strftime("%d/%m/%Y")}"
									dr.CodigoConcepto "001"
									amount_base = 0
									employee.all_payroll_payables_by_month_year(@payroll_regular_payroll_check.month,@payroll_regular_payroll_check.year).each do |payroll_regular_payroll_check|
										amount_base += employee.islr_listed? ? payroll_regular_payroll_check.base_amount_by_concept_and_employee(Payroll::Concept::ISLR,employee).amount_base :  payroll_regular_payroll_check.base_amount_by_concept_and_employee(Payroll::Concept::BASIC,employee).amount_allocated
									end
									dr.MontoOperacion amount_base
									dr.PorcentajeRetencion "#{employee.islr_percentage}"
								end
							end
					end

					out_file.close
					send_file file_name
			end
		end
	end
  
  def show_resumen_bank_file
    cont = 1
      @type_resumen_bank_file = params[:type_resumen_bank_file]
      @process_regular_payroll = Payroll::ProcessRegularPayroll.find(params[:process_regular_payroll_id])
        file = "#{RAILS_ROOT}/public/txt"
				if !File.exist?(file)
					system 'mkdir', '-p', file
				end
          file_name = "#{file}/#{@process_regular_payroll.payroll_payroll_type.name.to_underscore.upcase}_#{@process_regular_payroll.fortnight.to_code("02")}_#{@process_regular_payroll.month.to_code("02")}#{@process_regular_payroll.year}.txt"
					out_file = File.new(file_name, "w")
					@process_regular_payroll.payroll_regular_payroll_checks.each do |payroll_regular_payroll_check|
          payroll_regular_payroll_check.paid_employees.each do |employee|
						 amount_total = employee.amount_total_payroll_by_regular_payroll_check(payroll_regular_payroll_check)
             if @type_resumen_bank_file.eql?("payroll") and employee.account_number.split("-").join("").first(4).eql?("0163")
              out_file.puts("#{employee.nationality}#{employee.only_identification_document.to_i.to_code("09")}*#{employee.account_number.split("-").join("")}*#{amount_total.to_currency(false)}".upcase)
              cont += 1
             end
            if !@type_resumen_bank_file.eql?("payroll") and !employee.account_number.split("-").join("").first(4).eql?("0163")
               out_file.puts("#{employee.nationality}#{employee.only_identification_document.to_i.to_code("09")}*#{employee.account_number.split("-").join("")}*#{amount_total.to_currency(false)}*#{employee.name}".upcase)
               cont += 1
            end
					 end
					end
					 out_file.close
					send_file file_name    
  end

	def payment_receipt_by_employee
		@payment_receipt_cont = 1
		@regular_payroll_check = Payroll::RegularPayrollCheck.find_by_id(params[:last_payroll_id])
		@process_regular_payroll = @regular_payroll_check.payroll_process_regular_payroll
		@employee = Payroll::Employee.find_by_id(params[:employee_id])
		@employees = [@employee]
		respond_to do |format|
      format.html
      format.pdf do
				render :pdf                            => "payment_receipt_#{@regular_payroll_check.id}_by_employee_#{@employee.id}",
               :disposition                    => 'attachment',
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_size                      => 'Letter',
							 :orientation										 => 'Portrait',
							 :margin => {:top                => 10,
                           :bottom             => 10,
													 :right              => 2,
                           :left               => 5
 												 }
			end

		end
	end

	def masive_payment_receipt_by_employee
		@payment_receipt_cont = 2
		@process_regular_payroll = Payroll::ProcessRegularPayroll.find_by_id(params[:process_regular_payroll_id])
		@employees = @process_regular_payroll.payroll_employess
		file_path = "#{RAILS_ROOT}/public/pdfs/recibos/#{@payment_receipt_cont.month.to_code('02')}-#{@payment_receipt_cont.year}"
		save_path = "#{file_path}/RecibosNomina_#{@payment_receipt_cont.month.to_code('02')}-#{@payment_receipt_cont.year}.pdf"

				render :pdf                            => "payment_receipts_#{@payment_receipt_cont.id}",
               :disposition                    => 'attachment',
							 :template											 => "#{controller_path}/payment_receipt_by_employee.erb",
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_size                      => 'Letter',
							 :orientation										 => 'Portrait',
							 :margin => {:top                => 10,
                           :bottom             => 10,
													 :right              => 2,
                           :left               => 5
 												 }


	end

	def accept_massive_process
		@process_regular_payroll = Payroll::ProcessRegularPayroll.find(params[:process_regular_payroll_id])
		@process_regular_payroll.definitely_pay(current_user)
	end

	def send_payment_receipt_by_mail
		@payment_receipt_cont = 1
		@process_regular_payroll = Payroll::ProcessRegularPayroll.find(params[:process_regular_payroll_id])
		file_path = "#{RAILS_ROOT}/public/pdfs/recibos/#{@process_regular_payroll.month.to_code('02')}-#{@process_regular_payroll.year}"
		file_prefix = "ReciboPago"
		if !File.exist?(file_path)
					system 'mkdir', '-p', file_path
		end
		
		 @process_regular_payroll.payroll_regular_payroll_checks.each do |payroll_regular_payroll_check|
				payroll_regular_payroll_check.payroll_employess.each do |employee|
						@employees = [employee]
						file_name = "#{file_prefix}_#{employee.id}"
						pdf = render_to_string :pdf => file_name, :template => "#{controller_path}/payment_receipt_by_employee.erb", :layout =>	'backend/contable_document.html.erb'
						save_path = "#{file_path}/#{file_name}.pdf"
						File.open(save_path, 'wb') do |file|
							file << pdf
						end
				end
				payroll_regular_payroll_check.send_background_masive_payment_receipt_by_mail(file_prefix,file_path)
		end
		flash[:notice] = "Se esta llevando a cabo la acción en segundo plano"
		redirect_to(backend_human_resource_show_massive_process_url(@process_regular_payroll))
	end
end
