-- видеоскрипт для сайта https://uma.media (15/8/19)
-- открывает подобные ссылки:
-- https://uma.media/video/dcab9b90a33239837c0f71682d6606da/&referer=https://2x2tv.ru/online/
-- https://uma.media/play/embed/636ffab27c5a4a9cd5f9a40b2e70ea88
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('https?://uma%.media') then return end
	m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 3, Once = 1})
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = 'error'
	local id = inAdr:match('/video/(%w+)') or inAdr:match('/embed/(%w+)')
		if not id then return end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local refer = inAdr:match('referer=(.-)$') or inAdr
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://uma.media/api/play/options/' .. id .. '/?format=json', headers = 'Referer: ' .. refer})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('"hls":.-"url":%s*"(.-)"')
		if not retAdr then return end
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')