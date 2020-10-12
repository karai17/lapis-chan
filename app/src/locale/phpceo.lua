return { phpceo = {

	--==[[ Navigation ]]==--

	archive       = "Gallery Of Our Greatness",
	bottom        = "Best For Last",
	catalog       = "Products And Services",
	index         = "Home Page",
	refresh       = "Experience A Rejuvinating Meeting",
	["return"]    = "Reconsider",
	return_board  = "Reconsider that product",
	return_index  = "Reconsider that home page",
	return_thread = "Reconsider that email chain",
	top           = "I'm The Best",

	--==[[ Error Messages ]]==--

	-- Controller error messages
	err_ban_reason = "Hit 'enter' too early.",
	err_board_used = "That product name is in use, and we don't want to spend money on lawyers.",
	err_not_admin  = "Call HR.",
	err_orphaned   = "I accidentally lost the email chain about %s, do you know where it went?",
	err_slug_used  = "SEO CONFLICT, GOOGLE GROWTHHACK ERROR.",
	err_user_used  = "You can't be Brandon, *I'm* Brandon!",

	-- Model error messages
	err_contribute     = "Your argument needs more pictures or more words. I can't decide which. I'm fickle like that.",
	err_locked_thread  = "Email chain about %s is locked, I blame Outlook.",
	err_no_files       = "The cloud is busy, it does not want your attachments.",

	err_comment_post   = "Your pitch is great, except I don't know what you're talking about. Use your words.",
	err_comment_thread = "Did you seriously just try to send an email without a body? At least put in your signature. Have some pride, Intern.",

	err_create_ann     = "I couldn't stop yelling long enough to say: %s.",
	err_create_ban     = "These lottery numbers didn't work: %s.",
	err_create_board   = "I don't know how to make the product: /%s/ - %s.",
	err_create_page    = "Pages? No, we're paperless now, we don't need: /%s/ - %s.",
	err_create_post    = "I didn't read your email, let's set up a meeting in a few minutes where you read it to me.",
	err_create_report  = "I don't see anything wrong with an email about %s and I have no inclination to in my life.",
	err_create_thread  = "The reply button is broke! This is effecting production.",

	err_delete_board   = "I tried to delete those emails about: /%s/ - but I just couldn't %s.",
	err_delete_post    = "I clicked the flag, did that delete %s? No? Well what else am I supposed to do?",
	err_create_user    = "I don't know who %s is and frankly I don't give a big enough damn to learn.",

	err_file_exists    = "Johnson! I already have that spreadsheet! I think. Probably.",
	err_file_limit     = "THE CLOUD IS FULL, IF YOU SUBMIT ANYTHING ELSE TO %s THE INTERNET WILL GO DOWN.",
	err_file_post      = "If you want my attention you better use something other than words because I sure as hell ain't reading anything that comes across this desk today.",
	err_file_thread    = "This email chain said 'post your favorite confidential documents' but you forgot to attach any. Try that one again.",

	err_invalid_board  = "CORRUPT EMAIL: /%s/.",
	err_invalid_ext    = "Do I look like I know what a %s is?",
	err_invalid_image  = "It looks like you sent a picture but what I got was a digital clown.",
	err_invalid_post   = "Whatever %s was about, I've decided to politely disregard it as 'wrong opinion'.",
	err_invalid_user   = "I don't know who you are or what you're doing. I'm calling the police.",

	--==[[ 404 ]]==--

	["404"] = "404 - That's 3 better than a 401k!",

	--==[[ Administration ]]==--

	-- General
	admin_panel             = "CEO DASHBOARD",
	administrator           = "CEO",
	announcement            = "Important things that come out of my mouth",
	archive_days            = "Days to Archive Threads",
	archive_pruned          = "Gas these.",
	board                   = "Chain",
	board_group             = "Chain Group",
	board_title             = "Email Subject",
	bump_limit              = "Burp Excusal Tolerance",
	content_md              = "Markers",
	default_name            = "What is this?",
	draw_board              = "MSPAINT but for the Internet",
	file                    = "Datum gap",
	file_limit              = "Maximum Cloud Precipitation Ratio",
	global                  = "Everyone Has To Deal With",
	index_boards            = "Product Selection",
	janitor                 = "Unpaid Intern",
	login                   = "Clock In",
	logout                  = "Clock Out",
	moderator               = "Enforcer",
	num_pages               = "Reasons this company is great",
	num_threads             = "How much I can stand of this",
	password                = "Digital Hash Salt",
	password_old            = "That old thing.",
	password_retype         = "Do it again, it'll be funny.",
	post_comment_required   = "Need Context",
	post_file_required      = "Insert Meme",
	regen_thumb             = "Rectify Pixels",
	reply                   = "Interject",
	rules                   = "Things That Don't Apply To Me",
	name                    = "Bob",
	subtext                 = "sub-who?",
	success                 = "Me, The Physical Embodiment of Greatness",
	text_board              = "Stuff I Won't Read",
	theme                   = "Birthday Party",
	thread_comment_required = "CONVERSE BEFORE CLOUD",
	thread_file_required    = "INSERT FILE FOR CLOUD",
	slug                    = "CLOUD RESOURCE IDENTIFIER",
	username                = "User Identifcation String",
	yes                     = "I Am Glad To Blindly Accept This",
	no                      = "Not Exactly",

	-- Announcements
	create_ann   = "Open Mouth, Insert Foot",
	modify_ann   = "Damage Control",
	delete_ann   = "I never said that, you can't prove it.",
	created_ann  = "I believe %s is the lifeblood of this company.",
	modified_ann = "What I meant to say was actually %s.",
	deleted_ann  = "What announcement? %s you say? Doesn't ring a bell.",

	-- Boards
	create_board   = "More Email!",
	modify_board   = "Different Email",
	delete_board   = "Less Email!",
	created_board  = "How do you feel about /%s/ - %s? How about agilefall?",
	modified_board = "I hope we fixed the issue about /%s/ - %s because I was getting tired of covering for him.",
	deleted_board  = "I forgot I don't even like /%s/ - %s.",

	-- Pages
	create_page   = "Create new effigy to my greatness.",
	modify_page   = "Make this less bad.",
	delete_page   = "I ain't readin' this.",
	created_page  = "I heard about /%s/ - %s online, let me tell you how we can pivot this.",
	modified_page = "I saw some stuff about /%s/ - %s so I fixed it.",
	deleted_page  = "Good news, I got rid of those books about: /%s/ - %s.",

	-- Reports
	view_report    = "I said *what*?",
	delete_report  = "Forget about that.",
	deleted_report = "I changed my mind about %s and you can too.",

	-- Users
	create_user   = "Hire",
	modify_user   = "Rectify Person",
	delete_user   = "Get Rid Of",
	created_user  = "So %s is this bright young talent we've been hearing about.",
	modified_user = "Whatever was wrong with %s we squared away.",
	deleted_user  = "I got rid of that %s character for you.",

	--==[[ Archive ]]==--

	arc_display = "Displaying %{n_thread} expired %{p_thread} from the past %{n_day} %{p_day}",
	arc_number  = "In Britan they say 'pound'.",
	arc_name    = "Who?",
	arc_excerpt = "TL;DR",
	arc_replies = "Responses",
	arc_view    = "Investigate",

	--==[[ Ban ]]==--

	ban_title  = "Not allowed back!",
	ban_reason = "I decided I don't like you anymore, because: ",
	ban_expire = "I might forget about this on %{expire}.",
	ban_ip     = "And your stupid raffle ticket was: %{ip}.",

	--==[[ Catalog ]]==--

	cat_stats = "R: %{replies} / F: %{files}",

	--==[[ Copyright ]]==--

	copy_software = "You paid HOW MUCH for %{software}? And it's only version %{version}?! We should have used phpBB, it's way more mature.",
	copy_download = "Negotiate a license from %{github}",

	--==[[ Forms ]]==--

	form_ban                 = "Escort Off Property",
	form_ban_display         = "Not allowed in public",
	form_ban_board           = "Not allowed in my hosue",
	form_ban_reason          = "Why don't I like this person",
	form_ban_time            = "How long (in digital ages) to pretend I don't know this guy.",
	form_clear               = "Forget About It",
	form_delete              = "Hide Evidence",
	form_draw                = "Sketch Out",
	form_lock                = "END THIS",
	form_override            = "CLOUD IS LOOSE AND HUNGRY FOR DATA",
	form_readme              = "Frankly, I don't read the [%{rules}] and [%{faq}] so I won't ask you to, either. Hell, I don't even know what they say. And I wrote 'em!",
	form_remix               = "CLAIM AS YOUR OWN",
	form_report              = "I DON'T LIKE IT",
	form_required            = "MANDATORY IF YOU WANT TO KEEP WORKING HERE",
	form_save                = "Fwd to Offshore Account",
	form_sticky              = "IMMORTIALIZE SHAME",
	form_submit              = "HEMMORAGE BRILLIANCE",
	form_submit_name         = "EMPLOYEE ID NUMBER (PRE-ACQUISITION)",
	form_submit_name_help    = "Who are you again? A trip-what?",
	form_submit_subject      = "What Am I On About? Oh, Right.",
	form_submit_subject_help = "What I've brought you all here today to discuss",
	form_submit_options      = "Stock Options",
	form_submit_options_help = "sage: Don't let anyone know you're desperate for attention.",
	form_submit_comment      = "What you have to say.",
	form_submit_comment_help = "Tell us about your great idea.",
	form_submit_file         = "DATUMS",
	form_submit_file_help    = "FOREFIT YOUR DATA TO THE CLOUD",
	form_submit_draw         = "MSPAINT",
	form_submit_draw_help    = "MSPAINT OR GIMPIFY",
	form_submit_spoiler      = "Paywalled Content",
	form_submit_spoiler_help = "Increase viewer engagement 10%%",
	form_submit_mod          = "Enforcer of Marketability",
	form_submit_mod_help     = "Mark as landmine. Minesweeper humor. It means I think there's a bomb here.",
	form_width               = "Digital Horizon",
	form_height              = "Digital Embiggenment",

	--==[[ Posts ]]==--

	post_link     = "FORWARD THIS EMAIL",
	post_lock     = "EMAIL IS IN ARCHIVE MODE, STOP REPLYING TO THINGS I FORGOT ABOUT.",
	post_hidden   = "%{n_post} %{p_post} and %{n_file} %{p_file} omitted. %{click} to view.",
	post_override = "CLOUD STORAGE ENABLED",
	post_reply    = "Reply to this email",
	post_sticky   = "reply-all'd, cc'd the company, 10/10",
	post_save     = "I refuse to cut down on the fat, on account of all the words I said being fluff meant to distract you.",

	--==[[ Plurals ]]==--

	days = {
		one   = "digital age",
		other = "digital aegis"
	},
	files = {
		one   = "datum",
		other = "datums"
	},
	posts = {
		one   = "email",
		other = "emailadoodles"
	},
	threads = {
		one   = "email chain",
		other = "clusterfuck"
	},
}}
