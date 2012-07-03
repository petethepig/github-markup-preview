class HomeController < ApplicationController
  def index
    @markup = "" 
    @preview = "" 
    @types = []
    Renderer.types.keys.each do |key|
      @types << [Renderer.types[key]['name'], key]
    end
  end

  def renderr
    type = params[:type] || :gfm
    render :inline => Renderer.render(type.to_sym, params[:markup])
  end
end
