local scaleOffset = 0.8
function onCreatePost()
	for i = 0,7 do
		setPropertyFromGroup('strumLineNotes', i, 'texture', 'new'..(i < 4 and 'EXE' or '')..'notes')
		scaleObject('strumLineNotes.members['..i..']', getProperty('strumLineNotes.members['..i..'].scale.x') * 0.607 * scaleOffset, getProperty('strumLineNotes.members['..i..'].scale.y') * 0.607 * scaleOffset)
		setPropertyFromGroup('strumLineNotes', i, 'x', (i < 4 and 0 or (middlescroll and -134 or 90)) + 10 + 90 * i)
		if middlescroll and (i == 2 or i == 3) then setPropertyFromGroup('strumLineNotes', i, 'x', 10 + 90 * (i + 4) + 90) end
		setPropertyFromGroup('strumLineNotes', i, 'y', getProperty('strumLineNotes.members['..i..'].y') + 40 * (downscroll and 1 or -1))
	end
	for i = 0,getProperty('unspawnNotes.length')-1 do
		setPropertyFromGroup('unspawnNotes', i, 'texture', 'new'..(getProperty('unspawnNotes['..i..'].mustPress') and '' or 'EXE')..'notes')
		if not getProperty('unspawnNotes['..i..'].isSustainNote') then
			scaleObject('unspawnNotes['..i..']', getProperty('unspawnNotes['..i..'].scale.x') * 0.607 * scaleOffset, getProperty('unspawnNotes['..i..'].scale.y') * 0.607 * scaleOffset)
		else
			scaleObject('unspawnNotes['..i..']', getProperty('unspawnNotes['..i..'].scale.x') * 0.607 * scaleOffset, getProperty('unspawnNotes['..i..'].scale.y'))
			setProperty('unspawnNotes['..i..'].offset.x', -15)
		end
	end
end