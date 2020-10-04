-- видеоскрипт для https://cdnvideo.ru (4/10/20)
-- Copyright © 2017-2020 Nexterr
-- открывает подобные ссылки:
-- https://player.cdnvideo.ru/iframer.html?id=7SwGd3mioH
-- https://playercdn.cdnvideo.ru/aloha/players/uchalytv_player.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://player[%a]*%.cdnvideo%.ru') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	answer = answer:gsub('%s', '')
	local retAdr = answer:match('source:[\'"]([^\'"]+)') or answer:match('sourcesrc=[\'"]([^\'"]+)')
		if not retAdr then return end
	retAdr = retAdr:gsub('^//', 'http://')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
