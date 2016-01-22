-- /!\ ALART! /!\
return function(self, err)
	self.error      = err
	self.page_title = "Error"
	return { render = "error" }
end
