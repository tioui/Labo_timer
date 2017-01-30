note
	description: "A Web Page that use a template to fill it's body (content)"
	author: "Louis Marchand"
	date: "Sat, 28 Jan 2017 01:39:28 +0000"
	revision: "1.0"

class
	HTML_TEMPLATE_PAGE_RESPONSE

inherit
	WSF_PAGE_RESPONSE
		rename
			make as make_page
		end

create
	make

feature {NONE} -- Initialization

	make(a_template:TEMPLATE_FILE)
			-- Initialization of `Current' using `a_template'
			-- to fill it's body (content)
		do
			a_template.analyze
			a_template.get_output
			if attached a_template.output as output then
				make_with_body (output)
			else
				make_page
			end
			header.put_content_type_text_html
		end
end
