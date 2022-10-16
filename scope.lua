require("waveguide")
require("filter")

Scope = {}

function Scope:new(length)
	local new = {}
	setmetatable(new, self)
	self.__index = self

	new.input = {}
	for i = 1, 1024 do
		new.input[i] = 0
	end
	new.index = 1
	new.wait = false
	new.length = 44100 / 235

	return new
end

function Scope:update(a)
	--if not self.wait then
	self.input[self.index] = a
	self.index = self.index + 1
	if self.index > self.length * 2 then
		self.index = 1
		self.wait = true
	end
	--end
end

function Scope:draw()
	love.graphics.setColor(0.5, 1.0, 0.5)
	for i = 2, self.length * 2 do
		love.graphics.line(i - 1, 200 + self.input[i - 1] * 100, i, 200 + self.input[i] * 100)
	end
	self.wait = false
end
