Quadio = {}

love.audio.setEffect("reverb", {
	type = "reverb",
	gain = 0.2,
	decaytime = 4.0,
})

love.audio.setEffect("delay", {
	type = "echo",
	volume = 0.2,
	delay = 0.157,
	tapdelay = 0.044,
	damping = 0.5,
	feedback = 0.3,
	spread = 1.0,
})

function Quadio.load()
	bitDepth = 16
	samplingRate = 44100
	channelCount = 1
	-- With the above sampling rate, a buffer length of 1024 samplepoints should be enough.
	bufferSize = 1024
	pointer = 0
	sd = love.sound.newSoundData(bufferSize, samplingRate, bitDepth, channelCount)
	qs = love.audio.newQueueableSource(samplingRate, bitDepth, channelCount)

	qs:setEffect("reverb")
	qs:setEffect("delay")

	dspTime = 0.0

	fun = nil
end

function Quadio.setCallback(f)
	fun = f
end

function Quadio.update()
	if qs:getFreeBufferCount() == 0 then
		return
	end -- only render if we can.
	local samplesToMix = bufferSize -- easy way of doing things.
	for smp = 0, samplesToMix - 1 do
		-- put your generator function here.
		sd:setSample(pointer, fun(dspTime))
		pointer = pointer + 1
		dspTime = dspTime + (1 / samplingRate)
		if pointer >= sd:getSampleCount() then
			pointer = 0
			qs:queue(sd)
			qs:play()
		end
	end
end
