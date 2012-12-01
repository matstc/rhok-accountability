class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
    
  end
  
  def create
    session = GoogleDrive.login("rhokingout@gmail.com", "accountability1")
    spreadsheet = session.create_spreadsheet(params[:project_name])

    ws = session.spreadsheet_by_key("0AsNrDUUNJ35MdFJkOUZZaTNzeTdPQTRWNmV2ZzJydFE").worksheets[0]
    num_rows = ws.num_rows
    ws[num_rows, 1] = params[:phone_number]
    ws[num_rows, 2] = spreadsheet.key
    ws.save
    spreadsheet.acl.push({:scope_type => "user", :scope => params[:email], :role => "owner"})
    flash[:notice] = "Your new spreadsheet is available <a href='#{spreadsheet.human_url}'> here.</a>"
    redirect_to root_url
  end
  
end