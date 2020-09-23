return function(self)
	-- Logout
	self.session.name    = nil
	self.session.admin   = nil
	self.session.mod     = nil
	self.session.janitor = nil

	return { redirect_to = self:build_url() }
end
