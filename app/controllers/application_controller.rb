class ApplicationController < ActionController::Base
  @@DATABASE_SPREADSHEET_TITLE = "account.ability Database"
  
  protect_from_forgery

  before_filter :check_variables

  def check_variables
    if ENV['gmail'].blank? or ENV['gmailp'].blank?
      flash[:warning] = "The configuration variables \"gmail\" and \"gmailp\" are not set on the server. Creating a new ledger will not work.<br><br>Make sure you set these configuration variables and restart the server."
    end
  end

  def index
    redirect_to ledger_url
  end

  def create_ledger
    session = GoogleDrive.login(ENV['gmail'], ENV['gmailp'])

    file = session.upload_from_file("config/initializers/spreadsheet_template.xlsx","account.ability: "+params[:project_name], :content_type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    spreadsheet = session.spreadsheet_by_url(file.human_url)
    spreadsheet.worksheets.each {|ws|
      ws.max_cols = 100
      ws.max_rows = 200
      ws.save
    }
    spreadsheet.acl.push({:scope_type => "user", :scope => params[:email], :role => "owner"})
    
    number_to_key = session.spreadsheet_by_title(@@DATABASE_SPREADSHEET_TITLE)
    number_to_key = create_spreadsheet_database(session) if number_to_key.blank?
    
    phone_number = params[:phone_number].gsub(/[\(\)\-\s]/, '')
    
    puts "New Spreadsheet with phone number #{params[:phone_number]}, modified number #{phone_number}, project name #{params[:project_name]} and email address  #{params[:email]}"
    
    ws_number_to_key = number_to_key.worksheets[0]
    ws_number_to_key.list.push({"Phone Number" => phone_number, "Spreadsheet Key" => spreadsheet.key})
    ws_number_to_key.save
    flash[:notice] = "Your new spreadsheet is available <a href='#{spreadsheet.human_url}'> here.</a>"
    redirect_to individual_ledger_url
  end

  def create_spreadsheet_database session
    spreadsheet = session.create_spreadsheet(@@DATABASE_SPREADSHEET_TITLE)
    ws = spreadsheet.worksheets[0]
    ws[1,1] = "Phone Number"
    ws[1,2] = "Spreadsheet Key"
    ws.save
    spreadsheet
  end

  def add
    Rails::logger.info "Received #add request with params: #{params}"

    session = GoogleDrive.login(ENV['gmail'], ENV['gmailp'])
    ws_number_to_key = session.spreadsheet_by_title(@@DATABASE_SPREADSHEET_TITLE).worksheets[0]
    hash_row = ws_number_to_key.list.to_hash_array.find{|list_row| list_row["Phone Number"] == params[:From]}

    if hash_row.blank?
      hash_row = ws_number_to_key.list.to_hash_array.find{|list_row| list_row["Phone Number"] == params[:To]}
      raise "This phone number is not registered: #{params[:From]}." if hash_row.blank?
    end

    spreadsheet = session.spreadsheet_by_key(hash_row["Spreadsheet Key"])
    ws_data = spreadsheet.worksheet_by_title("data")
    
    if params[:Body].downcase == "help"
      client = Twilio::REST::Client.new ENV['twilio_id'], ENV['twilio_token']
      
    else  
      params[:Body].split(";").each{|expense|
        values = expense.split(",").map{|value| value.strip}
        
        new_row = [[Time.now, params[:From], *values]]
        new_row_index = ws_data.num_rows + 1
        puts "Updating spreadsheet (#{spreadsheet.title}) at row ##{new_row_index} with content: #{new_row}"
        ws_data.update_cells(new_row_index, 1, new_row)
      }
      ws_data.save
    end
  end
  
end
