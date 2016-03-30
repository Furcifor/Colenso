class FilesController < ApplicationController
	before_action :open_session
	before_action :parse_search_type

	DB_NAME = "Colenso"
	XQUERY = "XQUERY "
	NAMESPACE = "declare default element namespace 'http://www.tei-c.org/ns/1.0'; declare namespace tei = \"http://www.tei-c.org/ns/1.0\"; "
	ITERATE_WHOLE_COLLECTION = "for $n in (collection('#{DB_NAME}')) "
	RETURN_PATH =  " return db:path($n)"

	def index	
	end

	def all_files
		query = XQUERY + NAMESPACE + "for $n in (collection('#{DB_NAME}')) return db:path($n)"
		@results = @session.execute(query).split("\n")
	end

	def search
		perform_normal_search
	end

	def view_document
		@path = params[:path]
		@document = @session.execute(XQUERY + NAMESPACE + " db:open('#{DB_NAME}', '#{@path}')")
	end

	def add
	end

	def upload_document
		path = params[:addition_path]
		input = params[:xml].read

		@session.add(path, input)

		redirect_to "/view_document?path=#{path}"
	end

	def download
		path = params[:path]
    file_name = path.split("/").last
    send_data(@session.execute(XQUERY + NAMESPACE + " db:open('#{DB_NAME}', '#{path}')"), :type => 'application/xml', :filename => file_name)
  end

	private

	def open_session
		@session ||= BaseXClient.session
		@session.execute("OPEN #{DB_NAME}")
	end

	def perform_normal_search	
		search_input = params[:search]

		if search_input.present? && @search_type.present?
			case @search_type
			when 'XQuery'
				query = XQUERY + NAMESPACE + " #{search_input}"
				@search_result = @session.execute(query).split("\n")
			when 'XPath'
				query = XQUERY + NAMESPACE + "for $n in (collection('#{DB_NAME}')#{search_input}) return db:path($n)"
				@search_result = @session.execute(query).split("\n")
			else
				search_input = replace_logical_operators(search_input)
				query = XQUERY + NAMESPACE + " for $file in collection('#{DB_NAME}') where $file contains text #{search_input} using wildcards return db:path($file)"
				@search_result = @session.execute(query).split("\n")
			end
		end
  end

  def parse_search_type
  	@search_type = params[:search_type]
  end

  LOGICAL_REPLACEMENTS = [
    ["AND", "ftand"],
    ["&&" , "ftand"],
    ["OR" , "ftor"],
    ["||" , "ftor"],
    ["NOT", "ftnot"],
    ["!"  , "ftnot"]
  ]

  def replace_logical_operators(string)
    LOGICAL_REPLACEMENTS.each { |replacement| string.gsub!(replacement[0], replacement[1]) }
    string.split.map do |word|
      if word != "ftand" && word != "ftor" && word != "ftnot"
        "'#{word}'"
      else
        word
      end
    end.join(" ")
  end
end
