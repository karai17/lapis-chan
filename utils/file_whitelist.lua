-- A whitelist of filetypes
return {
	-- Image formats
	[".bmp"]  = true,
	[".png"]  = true,
	[".gif"]  = true,
	[".jpg"]  = true,
	[".jpeg"] = true,
	[".webp"] = true,
	[".svg"]  = false,

	-- Audio formats
	[".wav"]  = false,
	[".flac"] = false,
	[".mp3"]  = false,
	[".ogg"]  = false,

	-- Video formats
	[".mpg"]  = false,
	[".mpeg"] = false,
	[".avi"]  = false,
	[".mp4"]  = false,
	[".m4v"]  = false,
	[".mkv"]  = false,
	[".ogm"]  = false,
	[".webm"] = false,

	-- Archive formats
	[".zip"] = false,
	[".7z"]  = false,
	[".rar"] = false,
	[".tar"] = false,
	[".gz"]  = false,
	[".bz2"] = false,
	[".ace"] = false
}
