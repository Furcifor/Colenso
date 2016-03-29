class FilesController < ApplicationController
	def index
		@session = BaseXClient.session
		@results = @session.execute('LIST Colenso').split("\n")
	end
end
