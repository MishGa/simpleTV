-- видеоскрипт для сайта https://www.earthtv.com (29/4/20)
-- открывает подобные ссылки:
-- https://www.earthtv.com/en/webcam/new-york-brooklyn-bridge
-- https://www.earthtv.com/en
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAdress:match('^https?://www%.earthtv%.com') then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
	if not (inAdr:find('%.com/en$')
		and m_simpleTV.Control.ChannelID ~= 268435455)
	then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://www.earthtv.com/assets/images/nav_logo.svg', UseLogo = 1, Once = 1})
		end
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
		end
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'earthtv ошибка: ' .. str, showTime = 5000, color = ARGB(255, 255, 0, 0), id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36')
		if not session then
			showError('0')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			showError('1')
			m_simpleTV.Http.Close(session)
		 return
		end
	local token = answer:match('token: \'([^\']+)')
		if not token then
			showError('2')
		 return
		end
	local url = 'https://dapi-de.earthtv.com/api/v1/media.getPlayerConfig?playerToken=' .. token
	rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: https://player.earthtv.com/?token=' .. token})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('3')
		 return
		end
	require 'json'
	answer = answer:gsub('%[%]', '""')
	local tab = json.decode(answer)
		if not tab
			or not tab.streamUris
			or not tab.streamUris.hls
			or not tab.source
			or not tab.source.title
			or not tab.source.title.en
			or not tab.stream
			or not tab.stream.status
		then
			showError('4')
		 return
		end
		if tab.stream.status ~= 'online'
		then
			local err = '5 - ' .. tab.stream.status
			showError(err)
		 return
		end
	local retAdr = tab.streamUris.hls
	local title = tab.source.title.en
	if not (inAdr:find('%.com/en$')
		and m_simpleTV.Control.ChannelID ~= 268435455)
	then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			m_simpleTV.Control.ChangeChannelLogo('https://www.earthtv.com/assets/images/etv_logo.svg', m_simpleTV.Control.ChannelID)
		end
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	retAdr = retAdr
			.. '$OPT:NO-STIMESHIFT'
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')