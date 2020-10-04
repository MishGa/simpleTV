-- видеоскрипт для сайта https://www.mako.co.il (4/10/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- открывает ссылку:
-- https://www.mako.co.il/keshethlslive
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https://www%.mako%.co%.il/keshethlslive') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local stream = '/hls/live/512033/CH2LIVE_HIGH/index.m3u8'
	local url = 'https://mass.mako.co.il/ClicksStatistics/entitlementsServicesV2.jsp?et=gt&rv=AKAMAI&lp=' .. stream
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local token = answer:match('"ticket":"([^"]+)')
		if not token then return end
	local retAdr = 'https://keshethlslive-i.akamaihd.net' .. stream .. '?' .. token
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')