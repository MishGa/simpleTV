-- видеоскрипт для сайта http://filmhd1080.club (26/6/20)
-- необходимы скрипты: hdvb, collaps, videocdn, youtube
-- открывает подобные ссылки:
-- http://filmhd1080.club/3156-hvayugi-1-sezon-smotret-onlayn.html
-- http://filmhd1080.club/10607-arifureta-silneyshiy-remeslennik-v-mire-smotret-onlayn.html
-- http://filmhd1080.pro/11898-lezviya-slavy-zvezduny-na-ldu-2007-smotret-onlayn.html
-- http://filmhd1080.pro/1222-serial-strela-smotret-onlayn-hd.html
-- http://filmhd1080.club/11980-opasnye-sekrety-2019-smotret.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%.]*filmhd1080%..-/.+') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local host = inAdr:match('https?://[^/]+')
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = host .. '/templates/temp/images/logo.png', UseLogo = 1, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'filmhd1080 ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.2785.143 Safari/537.36')
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			showError('2')
			m_simpleTV.Http.Close(session)
		 return
		end
	answer = answer:gsub('<!%-%-.-%-%->', '')
	local title = answer:match('property="og:title" content="([^"]+)') or 'filmhd1080'
	title = title:gsub('смотреть в Full.-$', '')
	title = title:gsub('смотреть в 4K.-$', '')
	title = title:gsub('смотреть все серии.-$', '')
	title = title:gsub('%s+%d+.-сезон', '')
	title = title:gsub('%s+%d+.-Сезон', '')
	title = title:gsub('%(19%d+.+', '')
	title = title:gsub('%(20%d+.+', '')
	local poster = answer:match('<div class="polna%-poster">.-<img src="([^"]+)') or '/templates/temp/images/logo.png'
	poster = poster:gsub('^/', host .. '/')
	local desc = answer:match('"description" content="([^"]+)') or ''
	desc = desc:gsub('.+Описание %- ', '')
	local retAdr, name
	local i, t = 1, {}
		for adr in answer:gmatch('<div class="polna%-play tabs%-b video%-box">.-<iframe.-src="([^"]+)') do
				if not adr then break end
			if not adr:match('alloha') then
				t[i] = {}
				t[i].Id = i
				if adr:match('trailer%-cdn') then
					name = 'трейлер'
				else
					name = i .. ' HD плеер'
				end
				t[i].Name = name
				t[i].Address = adr
				t[i].InfoPanelName = title
				t[i].InfoPanelLogo = poster
				t[i].InfoPanelTitle = desc or name
				t[i].InfoPanelShowTime = 8000
				i = i + 1
			end
		end
		if i == 1 then
			showError('3')
		 return
		end
	if i > 2 then
		m_simpleTV.Control.SetTitle(title)
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 8000, 1)
		id = id or 1
		retAdr = t[id].Address
		m_simpleTV.Control.ExecuteAction(37)
	else
		retAdr = t[1].Address
	end
		if retAdr:match('trailer%-cdn') then
			rc, answer = m_simpleTV.Http.Request(session, {url = host .. retAdr, headers = 'Referer: ' .. inAdr})
			m_simpleTV.Http.Close(session)
				if rc ~= 200 then
					showError('4')
				 return
				end
			retAdr = answer:match('file:"([^"]+)')
				if not retAdr then
					showError('5')
				 return
				end
			retAdr = retAdr:gsub('^/', host .. '/')
			title = title .. ' - ' .. (answer:match('title:"([^"]+)') or 'trailer')
			m_simpleTV.Control.CurrentAddress = retAdr
			m_simpleTV.Control.CurrentTitle_UTF8 = title
				if retAdr:match('https?://[%a%.]*youtu[%.combe]') then
					m_simpleTV.Control.ChangeAddress = 'No'
					dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
				 return
				end
		 return
		end
	m_simpleTV.Http.Close(session)
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	retAdr = retAdr:gsub('^//', 'http://'):gsub('amp;', '')
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.CurrentAddress = retAdr .. '&kinopoisk'
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(retAdr .. '\n')