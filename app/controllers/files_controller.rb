class FilesController < ApplicationController
	before_action :open_session

	DB_NAME = "Colenso"
	XQUERY = "XQUERY "
	NAMESPACE = "declare default element namespace 'http://www.tei-c.org/ns/1.0'; "
	ITERATE_WHOLE_COLLECTION = "for $n in (collection('#{DB_NAME}')) "
	RETURN_PATH =  " return db:path($n)"

	def index
		@results = @session.execute("LIST #{DB_NAME}").split("\r")
	end

	def search
		search_input = params[:search]
		query = XQUERY + NAMESPACE + ITERATE_WHOLE_COLLECTION + "where $n contains text '#{search_input}'" + RETURN_PATH
		query_result = @session.execute(query)
		@search_result = query_result.split("\n")
	end

	private

	def open_session
		@session ||= BaseXClient.session
		@session.execute("OPEN #{DB_NAME}")
	end
end
