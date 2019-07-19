Waveguide = {}

function Waveguide:new(length)
	local new = {}	
	setmetatable(new, self)
	self.__index = self

	new.len = length

	new.fp = 0
	new.fp2 = 0

	new.r = {}
	new.l = {}
	for i = 0,new.len-1 do
		local x = i/(new.len)
		x = 0

		new.r[i] = x*0.5
		new.l[new.len - i - 1] = x*0.5
	end

	new.writeptr = 0

	new.length = new.len--math.floor(new.len*0.5)

	return new
end

function Waveguide:peek()
	local l = self:read(self.l,self.length)
	local r = self:read(self.r,self.length)

	return l,r
end

function Waveguide:put(refl_l,refl_r)
	self.l[(self.writeptr)%self.len] = refl_l
	self.r[(self.writeptr)%self.len] = refl_r

	self.writeptr = self.writeptr + 1
end

function Waveguide:draw()
	
	love.graphics.push()
	love.graphics.translate(10,200)

	local ys = -80
	local xs = 500/self.length

	for i = 0,math.floor(self.length)-2 do
		local r1 = self:getR(i)
		local r2 = self:getR(i+1)
		local l1 = self:getL(i)
		local l2 = self:getL(i+1)

		love.graphics.setColor(0,.8,0)
		love.graphics.line(i*xs,r1*ys,(i+1)*xs,r2*ys)
		love.graphics.setColor(.8,0,0)
		love.graphics.line(i*xs,l1*ys,(i+1)*xs,l2*ys)

		love.graphics.setColor(1,1,1)
		love.graphics.line(i*xs,(l1+r1)*ys,(i+1)*xs,(l2+r2)*ys)
	end

	
	love.graphics.pop()
end

function Waveguide:getL(i)
	i = math.floor(self.length) - i
	return self.l[(self.writeptr-i)%self.len]
end

function Waveguide:getR(i)
	return self.r[(self.writeptr-i-1)%self.len]
end

function Waveguide:read(t,i)
	local int = math.floor(i)
	local fract = i-int

	return t[(self.writeptr-int)%self.len]*(1-fract) + t[(self.writeptr-int-1)%self.len]*fract
end

function Waveguide:add(t,i,v)
	local int = math.floor(i)
	local fract = i-int

	t[(self.writeptr-int  )%self.len] = t[(self.writeptr-int  )%self.len] + (1-fract)*v
	t[(self.writeptr-int-1)%self.len] = t[(self.writeptr-int-1)%self.len] + (fract)*v
end