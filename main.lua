--[[
legato bug
make valve env linear

]]

require("waveguide")
require("horn")
require("scope")
require("qaudio")

--print console directly
io.stdout:setvbuf("no")

width = 800
height = 640

globaltime = 0

timer = 0

samples = 0

t = 0

sample = 0

mouseX_ = 0
mouseY_ = 0
mousePX_ = 0
mouseDX_ = 0

keyhole = 0.5

env = 0
env2 = 0
env3 = 0
keyOn = false

out = 0.1
lastZero = 0
fdetect = 0
pdetect = 0
ptarget = 32 --38

errp = 0
erri = 0
errd = 0

local octave = 0

keys = {
	-6,
	-5,
	-4,
	-3,
	-2,
	-1,
	0,
	-6,
	-5,
	-4,
	-3,
	-2,
	-1,
	0,
	-4,
	-3,
	-2,
	-1,
	0,
	-3,
	-2,
	-1,
	0,
	-2,
	-1,
	0,
	-4,
	-3,
	-2,
	-1,
	0,
}

-- print(#keys)

for k, v in pairs(keys) do
	print(k, v)
end

param = {
	-0.013200667274239,
	-0.017510339559265,
	-0.022888981499059,
	-0.029523198334262,
	-0.037736038266239,
	-0.047762424301628,
	-0.059965722025053,
	-0.072371529980717,
	-0.091087702147866,
	-0.11114586491364,
	-0.13416999889321,
	-0.1626324836453,
	-0.19605287123051,
	-0.23787127618823,
	-0.28865529935575,
	-0.34453017492341,
	-0.39876681848583,
	-0.46763376195722,
	-0.54572131719314,
	-0.75191280973749,
	-0.86653169379421,
	-0.98001317964498,
	-1.1159657705301,
	-1.1070956955478,
	-1.259605579122,
	-1.4391258357219,
	-1.6716961396856,
	-1.9020012612799,
	-2.1557265143301,
	-2.4422097153421,
	-2.7626185367762,
}
--love.window.setMode(width,height,{vsync=true,fullscreen=true,fullscreentype = "desktop",borderless = true, y=0})
love.window.setMode(width, height, { vsync = true, fullscreen = false, fullscreentype = "desktop", borderless = false })

function dsp(time)
	sample = sample + 1
	if keyOn then
		env = env * 0.99 + 1 * 0.01
	else
		env = env * 0.99
	end

	env2 = env2 + 40 / 44100
	--set env2 dynamics
	env2 = math.min(env2, mouseX_)

	if env3 < 1 then
		env3 = env3 + 0.5 / 44100
	end

	t = t + 1 / 44100
	mousePX_ = mouseX_
	mouseX_ = mouseX_ * 0.99 + (mouseX / width) * 0.01
	mouseY_ = mouseY_ * 0.99 + (mouseY / height) * 0.01

	mouseDX_ = mouseX_ - mousePX_

	--wave.length = 44100 / (440*2^((12*mouseY_/height)/12))
	pout = out

	out = horn:update()

	if out < 0.1 and pout > 0.10001 then
		fdetect = 1 / (t - lastZero)
		pdetect = 12 * math.log(fdetect / 440) / math.log(2) + 49

		errpp = errp

		errp = errp * 0.95 + (pdetect - ptarget) * 0.05
		erri = erri + errp * 0.01
		errd = errp - errpp

		if env3 < 0.2 then
			erri = 0
		end
		lastZero = t
	end
	scope:update(out)

	return out
end

function love.load()
	math.randomseed(os.time())
	love.math.setRandomSeed(os.time())

	love.graphics.setLineWidth(1)

	horn = Horn:new()
	scope = Scope:new()

	Quadio.load()
	Quadio.setCallback(dsp)
end

function love.update(dt)
	mouseX, mouseY = love.mouse.getPosition()

	globaltime = globaltime + dt

	-- for i = 1, 1 do
	-- 	dsp()
	-- end

	Quadio.update()

	if not love.keyboard.isDown("q", "w", "e", "r", "t", "y", "u", "i", "2", "3", "5", "6", "7", "a", "s", "d") then
		keyOn = false
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0, 0, 0)

	--horn.wave:draw()
	love.graphics.setColor(1, 1, 1)

	--print(horn.f)
	--print(errp,erri)

	love.graphics.line(horn.sx * 100 + 320, horn.sv / 100 + 400, horn.px * 100 + 320, horn.pv / 100 + 400)
	love.graphics.points(horn.sx * 100 + 320, horn.sv / 100 + 400)

	love.graphics.print("cents error: " .. math.floor(errp * 100 + 0.5))
	love.graphics.print("octave: " .. octave, 0, 16)

	scope:draw()

	--love.graphics.print("FPS: "..tostring(love.timer.getFPS( )),10,20)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	if key == "m" then
		erri = 0
	end

	--t = 0
	sample = 0

	local k = false

	if key == "q" then
		k = true
		ptarget = 38
	elseif key == "2" then
		k = true
		ptarget = 39
	elseif key == "w" then
		k = true
		ptarget = 40
	elseif key == "3" then
		k = true
		ptarget = 41
	elseif key == "e" then
		k = true
		ptarget = 42
	elseif key == "r" then
		k = true
		ptarget = 43
	elseif key == "5" then
		k = true
		ptarget = 44
	elseif key == "t" then
		k = true
		ptarget = 45
	elseif key == "6" then
		k = true
		ptarget = 46
	elseif key == "y" then
		k = true
		ptarget = 47
	elseif key == "7" then
		k = true
		ptarget = 48
	elseif key == "u" then
		k = true
		ptarget = 49
	elseif key == "i" then
		k = true
		ptarget = 50
	end

	-- if key == "d" then
	-- 	--print(horn.b)
	-- 	k = 1
	-- end
	-- if key == "a" then
	-- 	ptarget = ptarget + 1
	-- 	print(horn.b)
	-- 	k = 1
	-- end

	if key == "a" then
		octave = octave - 1
	elseif key == "s" then
		octave = octave + 1
	end

	if k then
		ptarget = ptarget + 12 * octave

		local p = keys[ptarget - 31] or 0

		print(ptarget - 31)
		print("p: " .. p)

		-- which valves to engage
		if p == 0 then
			horn.v1 = 0
			horn.v2 = 0
			horn.v3 = 0
		elseif p == -1 then
			horn.v1 = 0
			horn.v2 = 1
			horn.v3 = 0
		elseif p == -2 then
			horn.v1 = 1
			horn.v2 = 0
			horn.v3 = 0
		elseif p == -3 then
			horn.v1 = 1
			horn.v2 = 1
			horn.v3 = 0
		elseif p == -4 then
			horn.v1 = 0
			horn.v2 = 1
			horn.v3 = 1
		elseif p == -5 then
			horn.v1 = 1
			horn.v2 = 0
			horn.v3 = 1
		elseif p == -6 then
			horn.v1 = 1
			horn.v2 = 1
			horn.v3 = 1
		end
		--horn.v1 = horn.v1*0.6
		--horn.v2 = horn.v2*0.6
		--horn.v3 = horn.v3*0.6

		ftarget = math.pow(2, (ptarget - 49) / 12) * 440

		if keyOn == false then
			-- print("jump")

			--set valves instantly
			horn.v1_ = horn.v1
			horn.v2_ = horn.v2
			horn.v3_ = horn.v3
			--reset env only when not legato
			env2 = 0
			env3 = 0

			--quadratic from fit
			horn.b = -8.83e-3 + 6.94e-4 * ftarget - 3.94e-6 * ftarget * ftarget --param[ptarget - 31]

			--low notes from array
			if ptarget - 32 <= 5 then
				if param[ptarget - 31] then
					horn.b = param[ptarget - 31]
				end
			end
			print(horn.b)
		end

		keyOn = true
		erri = 0

		scope.length = 44100 / (233.09 * 2 ^ (p / 12))

		--local l = 44100/235--44100 / (235*2^(p/12))
		--horn.wave.length = l
	end
end
