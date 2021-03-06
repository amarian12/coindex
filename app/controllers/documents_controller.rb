class DocumentsController < ApplicationController

  def show
    @doc = Document.find_by_key(params[:id])
    if @doc.is_auth and !current_user
      render :nothing => true
    else
      render :inline => @doc.body.html_safe
    end
  end

  def api_v2
    render 'api_v2', layout: 'api_v2'
  end

  def websocket_api
    render 'websocket_api', layout: 'api_v2'
  end

  def fees
    render 'fees', layout: 'api_v2'
  end

  def terms
    render 'terms', layout: 'api_v2'
  end

  def contact
    render 'contact', layout: 'api_v2'
  end

end
