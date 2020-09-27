-- видеоскрипт для сайта http://www.melody.tv (19/8/18)
-- открывает ссылку: http://www.melody.tv/en-direct
-----------------------------------------------------------------------------------------
local cach = 0 -- размер кеша: 0 - не менять, 100-5000
-----------------------------------------------------------------------------------------
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('https?://[w.]*melody%.tv/en%-direct') then return end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('http[^\'\"<>]+%.m3u8')
		if not retAdr then return end
	if (cach >= 100 and cach <= 5000) then retAdr = retAdr .. '$OPT:network-caching=' .. cach end
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')