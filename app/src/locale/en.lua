return { en = {

	--==[[ Navigation ]]==--

	archive       = "Archive",
	bottom        = "Bottom",
	catalog       = "Catalog",
	index         = "Index",
	refresh       = "Refresh",
	["return"]    = "Return",
	return_board  = "Return to board",
	return_index  = "Return to index",
	return_thread = "Return to thread",
	top           = "Top",

	--==[[ Error Messages ]]==--

	-- Controller error messages
	err_ban_reason = "None given.",
	err_board_used = "Board name already in use.",
	err_not_admin  = "You are not an administrator.",
	err_orphaned   = "Thread No.%s has been orphaned.",
	err_slug_used  = "Page slug already in use.",
	err_user_used  = "Username already in use.",

	-- Model error messages
	err_contribute     = "You must post either a comment or a file.",
	err_locked_thread  = "Thread No.%s is locked.",
	err_no_files       = "Files are not accepted on this board.",

	err_comment_post   = "Comments are required to post on this board.",
	err_comment_thread = "Comments are required to post a thread on this board.",

	err_create_ann     = "Could not create announcement: %s.",
	err_create_ban     = "Could not ban IP: %s.",
	err_create_board   = "Could not create board: /%s/ - %s.",
	err_create_page    = "Could not create page: /%s/ - %s.",
	err_create_post    = "Could not submit post.",
	err_create_report  = "Could not report post No.%s.",
	err_create_thread  = "Could not create new thread.",

	err_delete_board   = "Could not delete board: /%s/ - %s.",
	err_delete_post    = "Could not delete post No.%s.",
	err_create_user    = "Could not create user: %s.",

	err_file_exists    = "File already exists on this board.",
	err_file_limit     = "Thread No.%s is at its file limit.",
	err_file_post      = "Files are required to post on this board.",
	err_file_thread    = "Files are required to post a thread on this board.",

	err_invalid_board  = "Invalid board: /%s/.",
	err_invalid_ext    = "Invalid filetype: %s.",
	err_invalid_image  = "Invalid image data.",
	err_invalid_post   = "Post No.%s is not a valid post.",
	err_invalid_user   = "Invalid username or password.",

	--==[[ 404 ]]==--

	["404"] = "404 - Page Not Found",

	--==[[ Administration ]]==--

	-- General
	admin_panel             = "Admin Panel",
	administrator           = "Administrator",
	announcement            = "Announcement",
	archive_days            = "Days to Archive Threads",
	archive_pruned          = "Archive Pruned Threads",
	board                   = "Board",
	board_group             = "Board Group",
	board_title             = "Board Title",
	bump_limit              = "Bump Limit",
	content_md              = "Content (Markdown)",
	default_name            = "Default Name",
	draw_board              = "Draw Board",
	file                    = "File",
	file_limit              = "Thread File Limit",
	filetype_image          = "Allow Image Files",
	filetype_audio          = "Allow Audio Files",
	global                  = "Global",
	index_boards            = "Current Boards",
	janitor                 = "Janitor",
	login                   = "Login",
	logout                  = "Logout",
	moderator               = "Moderator",
	num_pages               = "Active Pages",
	num_threads             = "Threads per Page",
	password                = "Password",
	password_old            = "Old Password",
	password_retype         = "Retype Password",
	post_comment_required   = "Post Comment Required",
	post_file_required      = "Post File Required",
	regen_thumb             = "Regenerate Thumbnails",
	reply                   = "Reply",
	rules                   = "Rules",
	name                    = "Name",
	subtext                 = "Subtext",
	success                 = "Success",
	text_board              = "Text Board",
	theme                   = "Theme",
	thread_comment_required = "Thread Comment Required",
	thread_file_required    = "Thread File Required",
	slug                    = "Slug",
	username                = "Username",
	yes                     = "Yes",
	no                      = "No",

	-- Announcements
	create_ann   = "Create Announcement",
	modify_ann   = "Modify Announcement",
	delete_ann   = "Delete Announcement",
	created_ann  = "You have successfully created announcement: %s.",
	modified_ann = "You have successfully modified announcement: %s.",
	deleted_ann  = "You have successfully deleted announcement: %s.",

	-- Boards
	create_board   = "Create Board",
	modify_board   = "Modify Board",
	delete_board   = "Delete Board",
	created_board  = "You have successfully created board: /%s/ - %s.",
	modified_board = "You have successfully modified board: /%s/ - %s.",
	deleted_board  = "You have successfully deleted board: /%s/ - %s.",

	-- Pages
	create_page   = "Create Page",
	modify_page   = "Modify Page",
	delete_page   = "Delete Page",
	created_page  = "You have successfully created page: /%s/ - %s.",
	modified_page = "You have successfully modified page: /%s/ - %s.",
	deleted_page  = "You have successfully deleted page: /%s/ - %s.",

	-- Reports
	view_report    = "View Report",
	delete_report  = "Delete Report",
	deleted_report = "You have successfully deleted report: %s.",

	-- Users
	create_user   = "Create User",
	modify_user   = "Modify User",
	delete_user   = "Delete User",
	created_user  = "You have successfully created user: %s.",
	modified_user = "You have successfully modified user: %s.",
	deleted_user  = "You have successfully deleted user: %s.",

	--==[[ Archive ]]==--

	arc_display = "Displaying %{n_thread} expired %{p_thread} from the past %{n_day} %{p_day}",
	arc_number  = "No.",
	arc_name    = "Name",
	arc_excerpt = "Excerpt",
	arc_replies = "Replies",
	arc_view    = "View",

	--==[[ Ban ]]==--

	ban_title  = "Banned!",
	ban_reason = "You have been banned for the following reason:",
	ban_expire = "Your ban will expire on %{expire}.",
	ban_ip     = "According to our server, your IP is: %{ip}.",

	--==[[ Catalog ]]==--

	cat_stats = "R: %{replies} / F: %{files}",

	--==[[ Copyright ]]==--

	copy_software = "Powered by %{software} %{version}",
	copy_download = "Download from %{github}",

	--==[[ Forms ]]==--

	form_ban                 = "Ban User",
	form_ban_display         = "Display Ban",
	form_ban_board           = "Local Ban",
	form_ban_reason          = "Reason for ban",
	form_ban_time            = "Length of time (in days) to ban user",
	form_clear               = "Clear",
	form_delete              = "Delete Post",
	form_draw                = "Draw",
	form_lock                = "Lock Thread",
	form_override            = "Unlimited Files",
	form_readme              = "Please read the [%{rules}] and [%{faq}] before posting.",
	form_remix               = "Remix Image",
	form_report              = "Report Post",
	form_required            = "required field",
	form_save                = "Save Thread",
	form_sticky              = "Sticky Thread",
	form_submit              = "Submit Post",
	form_submit_name         = "Name",
	form_submit_name_help    = "Give yourself a name and/or tripcode (optional)",
	form_submit_subject      = "Subject",
	form_submit_subject_help = "Define the topic of discussion (optional)",
	form_submit_options      = "Options",
	form_submit_options_help = "sage: post without bumping thread (more to come soon) (optional)",
	form_submit_comment      = "Comment",
	form_submit_comment_help = "Contribute to the discussion (or not)",
	form_submit_file         = "File",
	form_submit_file_help    = "Upload a file",
	form_submit_draw         = "Draw",
	form_submit_draw_help    = "Draw or remix an image",
	form_submit_spoiler      = "Spoiler",
	form_submit_spoiler_help = "Replace thumbnail with a spoiler-safe image",
	form_submit_mod          = "Moderator",
	form_submit_mod_help     = "Flag this thread",
	form_width               = "Width",
	form_height              = "Height",

	--==[[ Posts ]]==--

	post_link     = "Link to this post",
	post_lock     = "Thread is locked",
	post_hidden   = "%{n_post} %{p_post} and %{n_file} %{p_file} omitted. %{click} to view.",
	post_override = "Thread accepts unlimited files",
	post_reply    = "Reply to this post",
	post_sticky   = "Thread is stickied",
	post_save     = "Thread will not be pruned",

	--==[[ Plurals ]]==--

	days = {
		one   = "day",
		other = "days"
	},
	files = {
		one   = "file",
		other = "files"
	},
	posts = {
		one   = "post",
		other = "posts"
	},
	threads = {
		one   = "thread",
		other = "threads"
	},
}}
