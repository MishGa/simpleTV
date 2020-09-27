-- видеоскрипт для плейлиста "TV+" http://www.tvplusonline.ru (7/2/20)
-- открывает подобные ссылки:
-- http://tvplus.perviyhd
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAdress:match('^https?://tvplus%.') then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3538.102 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly93d3cudHZwbHVzb25saW5lLnJ1L2FwaTIvdjEvaGxzLw') .. inAdr:gsub('.+%.', '')})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('http[^\'"<>]+%.m3u8[^<>\'"]*')
	retAdr = retAdr or 'https://s3.ap-south-1.amazonaws.com/ttv-videos/InVideo___This_is_where_ypprender_1554571391885.mp4'
	retAdr = retAdr:gsub('\\u0026', '&')
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')