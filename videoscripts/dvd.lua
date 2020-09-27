-- видеоскрипт для просмотра DVD (23/7/18)
-- открывает файлы с расширением ifo, bup, vob, iso
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('^.:') then return end
	local adrEx = inAdr:gsub('%..-$', string.lower)
		if not (adrEx:match('%.ifo$')
				or adrEx:match('%.bup$')
				or adrEx:match('%.iso$')
				or adrEx:match('%.vob$'))
		then
		 return
		end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000 * 1, id = 'channelName'})
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local retAdr, name
	local title = 'DVD'
	if not adrEx:match('%.iso$') then
		require 'lfs'
		inAdr = inAdr:gsub('\\', '/')
		local path = inAdr:gsub('(.+/).-$', '%1')
		local IFO = false
		local VOB = false
		local namef
			for file in lfs.dir(path) do
				if lfs.attributes(path .. file, 'mode') == 'file' then
					namef = file:gsub('%..-$', string.lower)
					if namef:match('%.ifo$') or namef:match('%.bup$') then
						if IFO == false then
							IFO = true
						end
					end
					if namef:match('%.vob$') then
						if VOB == false then
							VOB = true
						end
					end
				end
			end
			if IFO == false then
				m_simpleTV.Control.ChangeAdress = 'No'
				m_simpleTV.Control.CurrentAdress = inAdr
			 return
			end
			if VOB == false then return end
		retAdr = 'dvd:///' .. path
		name = m_simpleTV.Common.multiByteToUTF8(path)
		name = name:gsub('/VIDEO_TS/', string.lower)
		name = name:gsub('/video_ts/', '')
	else
		name = m_simpleTV.Common.multiByteToUTF8(inAdr)
		name = name:gsub('.+\\(.-)%..-$', '%1')
		title = title .. ' - ' .. name
		retAdr = inAdr
	end
	if m_simpleTV.Control.CurrentTitle_UTF8 then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	m_simpleTV.OSD.ShowMessageT({text = title, color = ARGB(255, 155, 155, 255), showTime = 1000 * 5, id = 'channelName'})
	local t = {}
	t[1] = {}
	t[1].Id = 1
	t[1].Name = name
	t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'm_simpleTV.Control.ExecuteAction(96)'}
	t.ExtButton1 = {ButtonEnable = true, ButtonName = '📄', ButtonScript = 'm_simpleTV.Control.ExecuteAction(116)'}
	m_simpleTV.OSD.ShowSelect_UTF8('DVD', 0, t, 5000, 32 + 64 + 128)
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')