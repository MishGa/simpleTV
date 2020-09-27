-- видеоскрипт для сайта http://telekanalteatr.ru (30/9/18)
-- открывает: http://telekanalteatr.ru
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('https?://telekanalteatr%.ru') then return end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'http://telekanalteatr.ru/json/index.php', method = 'Post', headers = 'X-Requested-With: XMLHttpRequest\nReferer: http://telekanalteatr.ru/', body = 'r=0'})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('http[^\'\"<>]+%.m3u8[^<>\'\"]*')
		if not retAdr then return end
	m_simpleTV.Control.CurrentAdress = retAdr:gsub('\\/', '/')
-- debug_in_file(retAdr .. '\n')