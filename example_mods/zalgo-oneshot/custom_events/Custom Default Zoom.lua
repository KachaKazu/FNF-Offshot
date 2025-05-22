depende = false
zoomValue = 1
function onEvent(n,a,b)
    if n == 'Custom Default Zoom' then
        zoomValue = tonumber(a)
        local splitted = stringSplit(b, ', ')
        tween = tonumber(splitted[1])
		if tween == 0 then tween = tween + 0.0001 end
        ease = tostring(splitted[2]) or 'linear'

        if tween == nil then
            depende = false
            setProperty('defaultCamZoom', zoomValue)
        else
            depende = true
        end

        if zoomValue == 0 then
            zoomValue = 0.9
        end
        if zoomValue == nil then
            zoomValue = 0.9
        end

        if depende then
            doTweenZoom('zoomTween', 'camGame', zoomValue, tween, ease)
        end
    end
end
function onTweenCompleted(t)
    if t == 'zoomTween' then
        setProperty('defaultCamZoom', zoomValue)
    end
end