require("waveguide")

Flute = {}

function Flute:new(length)
	local new = {}	
	setmetatable(new, self)
	self.__index = self

	new.a = 0
	new.b = 0

	new.wave = Waveguide:new(400)
	new.wave.length = 44100/233
	new.valve1 = Waveguide:new(30)
	new.valve1.length = 23.19
	new.valve2 = Waveguide:new(20)
	new.valve2.length = 11.145
	new.valve3 = Waveguide:new(40)
	new.valve3.length = 36.028
	new.filter = 0
	new.filter2 = 0
	
	new.allpass = 0
	new.allpass2 = 0
	new.allpass3 = 0

	new.sv = 0
	new.sx = 0

	new.pv = 0
	new.px = 0

	new.v1 = 0
	new.v2 = 0
	new.v3 = 0

	new.v1_ = 0
	new.v2_ = 0
	new.v3_ = 0

	return new
end

function Flute:update()
 	self.px,self.pv = self.sx,self.sv

	local l,r = self.wave:peek()
	l,r = -l,-r


	dt = 1/(44100*1)

	local x = self.sx
	local y = self.sv
	local a = 0.05-0.20*env
	local b = self.b 

	--pitch env onset
	--b = b*(0.5+0.5*env2)

	if(keyOn) then
		--b = b + 0.04*errp + 0.04*erri --+ 0.5*errd
	end

	--error correction PID
	if env3 > 0.2 then
		b = b + (0.04*errp + 0.2*erri)
		b = math.min(b,1.0)
	end

	self.f = b

	

	--vibrato
	b = b*(1.0 + env3*0.1*math.sin(t*25 + 0.3*math.sin(t*17)))

	
	b = b*env --+ (-mouseX_+0.5)*0.5
	local g = 3500--3500


	for i = 1,1 do
		self.sv = self.sv + (g*g*a + g*g*b*x + g*g*x*x - g*x*y - g*g*x*x*x - g*x*x*y)*dt + love.math.randomNormal(0.1) + 220*l --220*r
		--self.sv = math.max(math.min(self.sv,44100),-44100)
		self.sx = self.sx + self.sv*dt 		
	end
	

	l = self.sx*0.5 + l * env2*0.6




	--0.99
	local a = 1.0--math.exp(-5*mouseY_)
	self.filter = self.filter*(1-a) + l*a
	a = 0.1 - 0.09*env2
	self.filter2 = self.filter2*(1-a) + self.filter*a
	l = (self.filter - self.filter2)
	--l = 1.0*clip((self.filter - self.filter2)*1.3)

	--l = 1.0*clip(l*1.5)

	--[[local k = 0.8
	local ap = self.allpass
	self.allpass = l - k*ap
	l = k*self.allpass + ap

	--k = 0.5

	ap = self.allpass2
	self.allpass2 = l - k*ap
	l = k*self.allpass2 + ap

	--k = 0.5
	ap = self.allpass3
	self.allpass3 = l - k*ap
	l = k*self.allpass3 + ap]]

	local spd = 0.002

	self.v1_ = self.v1_*(1.0-spd) + self.v1*spd
	self.v2_ = self.v2_*(1.0-spd) + self.v2*spd
	self.v3_ = self.v3_*(1.0-spd) + self.v3*spd


	local l1,r1 = self.valve1:peek()
	local l2,r2 = self.valve2:peek()
	local l3,r3 = self.valve3:peek()

	local o1 = self.v1_
	local o2 = self.v2_
	local o3 = self.v3_

	local a = r
	local b = a*(1.0-o1) + r1*o1
	local c = b*(1.0-o2) + r2*o2

	local d =  r2*(1.0-o3) + l3*o3
	local e = (r1*(1.0-o3) + l3*o3)*(1.0-o2) + l2*o2
	local f = ((r*(1.0-o3) + l3*o3)*(1.0-o2) + l2*o2)*(1.0-o1) + l1*o1

	


	self.valve1:put(e ,a)
	self.valve2:put(d ,b)
	self.valve3:put(r3,c)
  	  self.wave:put(f ,l)

	local out =  1.0*clip(l*0.7)

	return out
end

function clip(x)
	if(x <= -1) then
		return -2/3
	elseif(x >= 1) then
		return 2/3
	else
		return x-(x^3)/3
	end
end
