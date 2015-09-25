class DocumentsController < ApplicationController
	def show
    @document = Document.find params[:id]
	end

	def search
    if params[:q].nil?
      @documents = []
    else
      @documents = Document.search params[:q]
    end
  end

end
