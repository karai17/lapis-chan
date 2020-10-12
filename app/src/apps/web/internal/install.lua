local Users    = require "models.users"
local Boards   = require "models.boards"
local Pages    = require "models.pages"
local lfs      = require "lfs"
local validate = require("lapis.validate").validate
local faq      = [[
<div class="table_of_contents">
	<ol>
		<li><a href="#what-is-lapis-chan">What is Lapis-chan?</a></li>
		<li><a href="#what-is-lapchan">What is Lapchan?</a></li>
		<li><a href="#what-should-i-know">What should I know before posting?</a></li>
		<li><a href="#chan-101">What are the basics?</a></li>
		<li><a href="#anonymous">How do I post anonymously?</a></li>
		<li><a href="#image">Do I have to post an image?</a></li>
		<li><a href="#quote">How do I quote a post?</a></li>
		<li><a href="#tripcode">What is a tripcode?</a></li>
		<li><a href="#spoiler">Can I mark an image as a spoiler?</a></li>
		<li><a href="#post-options">What are post options?</a></li>
		<li><a href="#post-menu">How can I interact with posts?</a></li>
		<li><a href="#board-types">What types of boards are supported?</a></li>
	</ol>
</div>
<div class="answers">
	<div id="what-is-lapis-chan">
		<h2>What is Lapis-chan?</h2>
		<p>
			Lapis-chan is an open source imageboard web application written in Lua
			using the Lapis web framework.
		</p>
	</div>
	<div id="what-is-lapchan">
		<h2>What is Lapchan?</h2>
		<p>
			Lapchan is a website that runs the latest version of Lapis-chan. It is
			both used as a small community and a testing platform for new and
			experimental features.
		</p>
	</div>
	<div id="what-should-i-know">
		<h2>What Should I Know Before Posting?</h2>
		<p>
			Before posting, you should read the rules for whichever board you want to
			post in. If you break the rules, your post may be deleted and you may
			also earn yourself a temporary or permanent ban from the board or entire
			website. Please read the rules!
		</p>
	</div>
	<div id="chan-101">
		<h2>What are the Basics?</h2>
		<p>
			In general, "blue" boards are considered safe for work (SFW) and "red"
			boards are considered not safe for work (NSFW). The definition of
			work-safety is often loose, but in general it means there shouldn't be
			any direct pornographic material on a blue board. This may differ from
			site to site, but Lapis-chan by default offers blue and red themes that
			are nearly identical to 4chan's themes. New themes are expected in later
			releases.
		</p>
		<p>
			It is also worth noting that chan culture can be both friendly and
			abrasive. More often than not, users will be posting anonymously and are
			able to speak freely because if this. Be prepared for the best and worst
			of society when interacting with others in an anonymous forum.
		</p>
	</div>
	<div id="anonymous">
		<h2>How Do I Post Anonymously?</h2>
		<p>
			By default, all users are anonymous to each other. By leaving the "Name"
			field empty in a post, your name will simply be fille din with the
			board's default name. Identifiable information such as your IP address is
			recorded to the Lapis-chan database when you post for legal reasons, but
			all posts are permanently purged after some time unless otherwise noted,
			including your IP address and any other information attached to your
			post.
		</p>
	</div>
	<div id="image">
		<h2>Do I Have to Post an Image?</h2>
		<p>
			Some boards require you to post an image or a comment, others do not. By
			default, Lapis-chan will place "(Required)" in or near a field that
			requires data. Currently, Lapis-chan's only optionally required data
			include a comment and an image.
		</p>
	</div>
	<div id="quote">
		<h2>How Do I Quote a Post?</h2>
		<p>
			To quote (and link to) another post, simply type "&gt;&gt;" followed by
			the post number (e.g. &gt;&gt;2808). To quote a post that is on a
			different board, You must type "&gt;&gt;&gt;" follow by a slash, the
			name of the board, another slash, and then the post number
			(e.g. &gt;&gt;&gt;/a/2808).
		</p>
	</div>
	<div id="tripcode">
		<h2>What is a Tripcode?</h2>
		<p>
			A tripcode is a uniquely identifiable hash attached to the end of your
			name, or in lieu of a name. It is a completely optional feature that
			allows users to de-anonymize if they so choose. Some boards benefit from
			de-anonymization such as content-creation boards where being named can
			help get your content seen and recognized.
		</p>
		<p>
			Tripcodes come in two sizes: insecure and secure. Insecure tripcodes use
			a weak hashing method that allows users to game the algorithm to generate
			a hash that reads out something similar to what they want. A secure
			tripcode uses a very secure hashing algorithm and a server-specific
			secret token that is not gameable, but also significantly more difficult
			to impersonate.
		</p>
		<p>
			To use an insecure tripcode, place a hash ("#") sign at the end of your
			name (or leave a name out entirely) and type your password after the
			hash. To use a secure tripcode, simply use two hashes instead of one
			(e.g. lapchan#insecure, lapchan##secure, #nameless, ##nameless).
		</p>
	</div>
	<div id="spoiler">
		<h2>Can I Mark an Image as a Spoiler?</h2>
		<p>
			Yes. When you upload an image, there should be a check box beside the
			file input field. Checking that box will replace the thumbnail of your
			image with a spoiler image.
		</p>
		<p>
			You can also tag text within your post as a spoiler by writing your text
			with [spoiler]a spoiler tag[/spoiler].
		</p>
	</div>
	<div id="post-options">
		<h2>What Are Post Options?</h2>
		<p>
			Post options are optional features you can use to modify how your post
			affects the thread or board you are posting in. To apply an options,
			simply type the option code into the options field in your post.
			Currently, the options available include:
		</p>
		<ul>
			<li>sage - Do not bump the thread with your post.</li>
		</ul>
	</div>
	<div id="post-menu">
		<h2>How Can I Interact With Posts?</h2>
		<p>
			To interact with a post, click on the menu icon ("▶") on the left of the
			post. The menu currently has the following interactions:
		</p>
		<ul>
			<li>
				Report Post - Report a post to moderators that you believe is breaking
				the rules of the board.
			</li>
			<li>
				Delete Post - Delete your own post. Lapis-chan saves a unique password
				to your user session when you make your first post and will allow you
				to delete any post you make as long as you are using the same session.
			</li>
			<li>
				Remix Image - Draw boards have a remix feature that allows you to copy
				the image from a post into the drawing canvas and draw on top of it.
				You can then post your new image in the thread to show off your
				updated image.
			</li>
		</ul>
	</div>
	<div id="board-types">
		<h2>What Types of Boards are Supported?</h2>
		<p>
			Lapis-chan has several different types of boards with more planned in the
			future. Currently, Lapis-chan supports the following boards:
		</p>
		<ul>
			<li>
				Image boards - Upload images and chat with other people about various
				topics or sub-topics. Common image boards include discussing your
				favourite TV shows, video games, or characters within.
			</li>
			<li>
				Text boards - Strictly text. Common text boards include discussing
				latest events, breaking news, politics, or writing stories.
			</li>
			<li>
				Draw boards - Upload, draw, and remix images. Common draw boards
				include art critiquing and art remixing.
			</li>
		</ul>
	</div>
</div>
]]

local success = [[
<h2>
	Congratulations! Lapis-chan is now installed! Please  rename or delete the
	`install.lua` file to see your new board. Visit "/admin" to get started!
<h2>
<h2>Thank you for installing Lapis-chan! &lt;3</h2>
]]

return {
	GET = function(self)
		self.page_title = "Install Lapis-chan"
		self.board      = { theme = "yotsuba_b" }

		-- Do we already have data?
		local users  = Users:get_users()
		local boards = Boards:get_boards()
		local pages  = Pages:get_pages()

		-- We did it!
		if #users > 0 and #boards > 0 and #pages > 0 then
			return success
		end

		-- Get list of themes
		self.themes = {}
		for file in lfs.dir("."..self.styles_url) do
			local name, ext = string.match(file, "^(.+)(%..+)$")
			if name ~= "reset"  and
				name ~= "posts"  and
				name ~= "style"  and
				name ~= "tegaki" and
				ext  == ".css"   then
				table.insert(self.themes, name)
			end
		end

		return { render = "install" }
	end,
	POST = function(self)
		self.page_title = "Install Lapis-chan"
		self.board      = { theme = "yotsuba_b" }

		-- Do we already have data?
		local users  = Users:get_users()
		local boards = Boards:get_boards()
		local pages  = Pages:get_pages()

		-- We did it!
		if #users > 0 and #boards > 0 and #pages > 0 then
			return success
		end

		local errs = validate(self.params, {
			{ "user_username", exists=true, max_length=255 },
			{ "user_password", min_length=4, max_length=255 },
			{ "name", exists=true, max_length=10 },
			{ "title", min_length=2, max_length=255 },
			{ "subtext", max_length=255 },
			{ "rules" },
			{ "ban_message", max_length=255 },
			{ "anon_name", max_length=255 },
			{ "theme", exists=true },
			{ "pages", exists=true },
			{ "threads_per_page", exists=true },
			{ "thread_file_limit", exists=true },
			{ "post_limit", exists=true },
			{ "thread_file", exists=true },
			{ "thread_comment", exists=true },
			{ "post_file", exists=true },
			{ "post_comment", exists=true },
			{ "text_only", exists=true },
			{ "filetype_image", exists=true },
			{ "filetype_audio", exists=true },
			{ "draw", exists=true },
			{ "archive", exists=true },
			{ "archive_time", exists=true },
			{ "group", exists=true }
		})

		local out
		if errs then
			out = "<div class='install'>\n"
			for _, err in ipairs(errs) do
				out = out .. "<h2>" .. err .. "</h2>\n"
			end
			out = out .. [[
				<form action="" method="get">
					<button>Return</button>
				</form>
			</div>
			]]
		end

		if out then
			return out
		end

		-- Add new user
		Users:create_user {
			username = self.params.user_username,
			password = self.params.user_password,
			admin    = true,
			mod      = false,
			janitor  = false
		}

		-- Add new board
		Boards:create_board {
			name        = self.params.name,
			title             = self.params.title,
			subtext           = self.params.subtext,
			rules             = self.params.rules,
			anon_name         = self.params.anon_name,
			theme             = self.params.theme,
			posts             = 0,
			pages             = self.params.pages,
			threads_per_page  = self.params.threads_per_page,
			text_only         = self.params.text_only,
			filetype_image    = self.params.filetype_image,
			filetype_audio    = self.params.filetype_audio,
			draw              = self.params.draw,
			thread_file       = self.params.thread_file,
			thread_comment    = self.params.thread_comment,
			thread_file_limit = self.params.thread_file_limit,
			post_file         = self.params.post_file,
			post_comment      = self.params.post_comment,
			post_limit        = self.params.post_limit,
			archive           = self.params.archive,
			archive_time      = self.params.archive_time * 24 * 60 * 60,
			group             = self.params.group
		}

		-- Add FAQ page
		Pages:create_page {
			name    = "Frequently Asked Questions",
			url     = "faq",
			content = faq
		}
	end
}
