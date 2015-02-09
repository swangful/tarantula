class CsvExportsController < ApplicationController
  layout false
  
  before_filter do |c|
    c.require_permission(['TEST_DESIGNER'])
  end
  
  def new
  end
  
  def create
    test_area = @current_user.test_area(@project)
    klass = params[:export_type].camelcase.constantize
    if @test_area
      records = @test_area.send(klass.to_s.downcase.pluralize.to_sym).send(:active)
    else
      records = klass.active.where(:project_id => @project.id)
    end
    
    csv = klass.to_csv(';', "\r\n", :recurse => params[:recursion].to_i,
          :export_without_ids => !params[:export_without_ids].blank?) { records }
    
    #if a user selects single case radio and selects a case
    #then send the user the csv file with the selected case only
    if :export_type = "single_case"
      send_data csv, :options = {s.title}
                    :filename => "#{params[:export_type]}_export.csv",
                    :disposition => 'attachment'
    else
      send_data csv, :filename => "#{params[:export_type]}_export.csv",
                   :disposition => 'attachment'
    end
  end
end
