return function(self)
	-- Logout
	self.session.name    = nil
	self.session.admin   = nil
	self.session.mod     = nil
	self.session.janitor = nil

	return { redirect_to = self:url_for("index") }
end
