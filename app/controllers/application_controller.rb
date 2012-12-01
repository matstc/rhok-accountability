class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
    
  end
  
  def create
    session = GoogleDrive.login("rhokingout@gmail.com", "accountability1")
    spreadsheet = session.create_spreadsheet(params[:project_name])
    ws_generated = spreadsheet.worksheets[0]
    ws_generated.list.keys = ["timestamp", "phone number", "item", "description", "amount"]
    ws_generated.list.push({"timestamp" => "12/1/2012 13:55:16", 
                       "phone number" => "+14692086681", 
                       "item" => "pencil", 
                       "description" => "lost the previous", 
                       "amount" => "2.50"})
                       
    ws_generated.save
    
    ws_number_to_key = session.spreadsheet_by_key("0AsNrDUUNJ35MdFJkOUZZaTNzeTdPQTRWNmV2ZzJydFE").worksheets[0]
    num_rows = ws_number_to_key.num_rows
    ws_number_to_key[num_rows, 1] = params[:phone_number]
    ws_number_to_key[num_rows, 2] = spreadsheet.key
    ws_number_to_key.save
    spreadsheet.acl.push({:scope_type => "user", :scope => params[:email], :role => "owner"})
    flash[:notice] = "Your new spreadsheet is available <a href='#{spreadsheet.human_url}'> here.</a>"
    redirect_to root_url
  end
  
end