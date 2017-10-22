note
	description: "Every class using views should inherit from this class."
	author: "Louis Marchand"
	date: "Mon, 03 Apr 2017 03:20:30 +0000"
	revision: "0.1"

deferred class
	VIEWS_SHARED

inherit
	CONFIGURATION_SHARED

feature {NONE} -- Implementation

	views_path:READABLE_STRING_GENERAL
			-- The path of the views directory
		do
			if attached {READABLE_STRING_GENERAL} configurations.at ("views_directory") as la_views_directory then
				Result := la_views_directory
			else
				Result := "./views"
			end
		end

end
