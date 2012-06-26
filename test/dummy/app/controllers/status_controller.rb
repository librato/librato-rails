class StatusController < ApplicationController
  def index
    render :nothing => true, :status => params[:code]
  end
end
