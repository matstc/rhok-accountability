class ApplicationController < ActionController::Base
  @@DATABASE_SPREADSHEET_TITLE = "ACCOUNTability Database"
  
  protect_from_forgery

  def index
    if ENV['gmail'].blank? or ENV['gmailp'].blank?
      flash[:warning] = "The configuration variables \"gmail\" and \"gmailp\" are not set on the server. Creating a new ledger will not work.<br><br>Make sure you set these configuration variables and restart the server."
    end
  end
  
  def create
    session = GoogleDrive.login(ENV['gmail'], ENV['gmailp'])

    file = session.upload_from_file("config/initializers/ACCOUNTability.xlsx","ACCOUNTability: "+params[:project_name], :content_type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    spreadsheet = session.spreadsheet_by_url(file.human_url)
    spreadsheet.worksheets.each {|ws|
      ws.max_cols = 100
      ws.max_rows = 200
      ws.save
    }


    
    number_to_key = session.spreadsheet_by_title(@@DATABASE_SPREADSHEET_TITLE)
    number_to_key = create_spreadsheet_database(session) if number_to_key.blank?
    
    ws_number_to_key = number_to_key.worksheets[0]
    ws_number_to_key.list.push({"Phone Number" => params[:phone_number], "Spreadsheet Key" => spreadsheet.key})
    ws_number_to_key.save
    spreadsheet.acl.push({:scope_type => "user", :scope => params[:email], :role => "owner"})
    flash[:notice] = "Your new spreadsheet is available <a href='#{spreadsheet.human_url}'> here.</a>"
    redirect_to root_url
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
    session = GoogleDrive.login(ENV['gmail'], ENV['gmailp'])
    ws_number_to_key = session.spreadsheet_by_key(ENV['spreadsheet_key']).worksheets[0]
    hash_row = ws_number_to_key.list.to_hash_array.find{|list_row| list_row["Phone Number"] == params[:From]}
    raise "This phone number is not registered: #{params[:From]}." if hash_row.blank?
        
    ws_account = session.spreadsheet_by_key(hash_row["Spreadsheet Key"]).worksheet_by_title("data")
    values = params[:Body].split(",").map{|value| value.strip}
        
    ws_account.list.push({"timestamp" => Time.now, 
                           "phone number" => params[:From], 
                           "item" => values[0], 
                           "description" => values[2], 
                           "amount" => values[1]})
    ws_account.save
  end
  
  #def addNumber
  #  session = GoogleDrive.login(ENV['gmail'], ENV['gmailp'])
  #  ws_number_to_key = session.spreadsheet_by_key(ENV['spreadsheet_key']).worksheets[0]
  #  hash_row = ws_number_to_key.list.to_hash_array.find{|list_row| list_row["Phone Number"] == params[:old_number]}
  #  ws_number_to_key.list.push({"Phone Number" => params[:new_number], 
  #                     "Spreadsheet Key" => hash_row["Spreadsheet Key"]})
  #  ws_number_to_key.save
  #  session.spreadsheet_by_key(hash_row["Spreadsheet Key"]).acl.push({:scope_type => "user", :scope => params[:email], :role => "viewer"})
    
  #end
  
  
end
