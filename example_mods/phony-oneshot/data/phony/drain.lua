local drainAmount = 0.00005
local complexDrain = false
local oppDrain = false

function onCreatePost()
	makeLuaSprite('fog', 'fog')
	setObjectCamera('fog', 'hud')
	scaleObject('fog', 2, 2)
	setProperty('fog.antialiasing', false)
	setProperty('fog.alpha', 0)
	addLuaSprite('fog', true)
end

function onBeatHit()
	if curBeat == 144 then
		oppDrain = true
	end
	if curBeat == 260 then
		oppDrain = false
		setHealth(2)
		setProperty('healthGain', 0)
	end
	if curBeat == 296 then
		complexDrain = true
	end
	if curBeat == 848 then
		complexDrain = false
		setProperty('healthGain', 1)
	end
end

function onUpdatePost()
	if complexDrain then
		addHealth(-drainAmount)
		setProperty('fog.alpha', 1 - getHealth() / 2)
	end
end

function opponentNoteHit(id, nd, nt, isn)
	if not isn and oppDrain then
		addHealth(-0.0155)
	end
end