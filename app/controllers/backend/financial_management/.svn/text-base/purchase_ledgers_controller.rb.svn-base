class Backend::FinancialManagement::PurchaseLedgersController < Backend::FinancialManagement::BaseController
  def index
		@title = "Libro de Compras"
    @incoming_invoices = AccountPayable::IncomingInvoice.all_group_by_month_year

  end

	def show
		@title = "Libro de Compras / Detalle mes"
		result = AccountPayable::IncomingInvoice.all_by_month_year(params[:id])
		@incoming_invoices = result[:records]
		@taxes = result[:taxes]
		@with_exempts = result[:with_exempts]
		@month_date = params[:id]
    year,month = @month_date.split("-").map(&:to_i)
    @period = "01/#{month.to_code("02")}/#{year} AL #{Date.civil(year, month, -1).day}/#{month.to_code("02")}/#{year}"
		respond_to do |format|
					format.html
					format.pdf do
            @title = "LIBRO DE COMPRAS DEL  #{@period}"
						render :pdf                            => "PurchaseLedgers_#{@month_date}",
									 :disposition                    => 'attachment',
									 :layout												 =>	'backend/contable_document.html.erb',
									 :orientation                    => 'Landscape',
									 :page_size												=> 'Legal',

									 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document_with_fiscal_info.erb'},
																:left => '2'
																},
									 :margin => {:top                => 25,
															 :bottom             => 15,
															 :right              => 5,
															 :left               => 5
														 }
					end
          format.csv do
            path_to_save = "#{RAILS_ROOT}/public/csv"
          file_name = "#{path_to_save}/empleados.csv"
          if !File.exist?(path_to_save)
            system 'mkdir', '-p', path_to_save
          end

          	 owner = Supplier.find_owner
              contact = owner.contact
              CSV.open(file_name, "wb",  ';' ) do |csv|
                          csv << [Iconv.iconv('iso8859-1','utf-8', contact.fullname.upcase).first]
                          csv << [Iconv.iconv('iso8859-1','utf-8',contact.address).first]

                          csv << []
                          header = []
                          header = [
                                    Iconv.iconv('iso8859-1','utf-8',"Oper Nro").first,
                                    Iconv.iconv('iso8859-1','utf-8',"Fecha de la factura").first,
                                    Iconv.iconv('iso8859-1','utf-8',"R.I.F.").first,
                                    Iconv.iconv('iso8859-1','utf-8',"Nombre o Razon Social").first,
                                    Iconv.iconv('iso8859-1','utf-8',"Tipo de proveedor").first,
                                    Iconv.iconv('iso8859-1','utf-8',"Nro. Factura").first,
                                    Iconv.iconv('iso8859-1','utf-8',"Nro. Control").first,
                                    Iconv.iconv('iso8859-1','utf-8',"Nro. N/Cred").first,
                                    Iconv.iconv('iso8859-1','utf-8',"Nro. N/Deb").first,
                                    Iconv.iconv('iso8859-1','utf-8',"Tipo Transaccion").first,
                                    Iconv.iconv('iso8859-1','utf-8',"Nro. Factura Afectada").first,
                                    Iconv.iconv('iso8859-1','utf-8',"Total compras incluyendo I.V.A.").first
                                    ]
                                    @taxes.each do |tax|
                                        unless tax.exempt
                                            header << Iconv.iconv('iso8859-1','utf-8',"Base imponible alic. (#{tax.amount.to_currency(false)})").first
                                            header << Iconv.iconv('iso8859-1','utf-8',"Impuesto IVA (#{tax.amount.to_currency(false)})").first
                                        end
                                        if @with_exempts
                                            header << Iconv.iconv('iso8859-1','utf-8',"Exentas y/o Sin Derecho a Credito Fiscal").first
                                        end
                                    end
                                    header << Iconv.iconv('iso8859-1','utf-8',"IVA Retenido").first
                                    csv << header.map(&:upcase)
                                     cont = 0
                                    @incoming_invoices.each do |incoming_invoice|
                                      cont += 1
                                          data =    [
                                                Iconv.iconv('iso8859-1','utf-8',"#{cont.to_code}").first,
                                                Iconv.iconv('iso8859-1','utf-8',"#{incoming_invoice.invoice_date.to_date}").first,
                                                Iconv.iconv('iso8859-1','utf-8',"#{incoming_invoice.tenderer.contact.rif}").first,
                                                Iconv.iconv('iso8859-1','utf-8',"#{incoming_invoice.tenderer.name}").first,
                                                Iconv.iconv('iso8859-1','utf-8',incoming_invoice.tenderer.contact.is_natural? ? "PN" : "PJ").first,
                                                Iconv.iconv('iso8859-1','utf-8',"#{incoming_invoice.reference}").first,
                                                Iconv.iconv('iso8859-1','utf-8',"#{incoming_invoice.control_number}").first,
                                                Iconv.iconv('iso8859-1','utf-8',"").first,
                                                Iconv.iconv('iso8859-1','utf-8',"").first,
                                                Iconv.iconv('iso8859-1','utf-8',"01-REG").first,
                                                Iconv.iconv('iso8859-1','utf-8',"").first,
                                                Iconv.iconv('iso8859-1','utf-8',"#{incoming_invoice.total_amount.to_currency(false)}").first,
                                              ]
                                        taxes_by_invoices = {}
                                        
                                        @taxes.each do |tax|

                                          unless tax.exempt
                                            
                                            tax_amount_taxes_by_tax = incoming_invoice.tax_amount_taxes_by_tax(tax)
                                            taxable_taxes_by_tax = incoming_invoice.taxable_taxes_by_tax(tax)
                                            
                                            tax_amount_additional += tax_amount_taxes_by_tax if tax.additional
                                            tax_amount_reduced += tax_amount_taxes_by_tax if tax.reduced
                                            unless taxes_by_invoices.has_key?(tax.id)
                                              taxes_by_invoices[tax.id] = {:taxable => 0,:tax_amount => 0}
                                            end
                                            taxes_by_invoices[tax.id][:taxable]  += taxable_taxes_by_tax
                                            taxes_by_invoices[tax.id][:tax_amount] += tax_amount_taxes_by_tax
                                            data << Iconv.iconv('iso8859-1','utf-8',"#{taxable_taxes_by_tax.to_currency(false)}").first
                                            data << Iconv.iconv('iso8859-1','utf-8',"#{tax_amount_taxes_by_tax.to_currency(false)}").first
                                          end
                                          if @with_exempts
                                              data << Iconv.iconv('iso8859-1','utf-8',"#{incoming_invoice.amount_exempt.to_currency(false)}").first
				                                  end
                                      end
                                      csv << data
                                    end
                    end
          send_file file_name,:type => "text/csv;"
          end
		end
	end

  def search_by_date

  end

end
