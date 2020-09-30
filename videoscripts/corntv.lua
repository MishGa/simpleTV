-- видеоскрипт для плейлиста "corntv" http://corntv.ru (29/9/20)
-- Copyright © 2017-2020 Nexterr
-- ## необходим ##
-- скрапер TVS: corntv_pls.lua
-- открывает подобные ссылки:
-- http://corntv.ru/live-tv/ru-tv.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://corntv%.ru/live') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('http[^\'\"<>]+%.m3u8[^<>\'\"]*')
		if not retAdr then return end
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')