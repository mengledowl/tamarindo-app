class LogonAtsController < ApplicationController
  def show
    response = Logon.get_ats(params[:id])
    render json: response
  end
end