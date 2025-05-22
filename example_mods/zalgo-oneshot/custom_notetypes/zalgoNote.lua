function onCreate()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getProperty('unspawnNotes['..i..'].noteType') == 'zalgoNote' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'hurtnote')
		end
	end
end