-- видеоскрипт для плейлиста "vinteratv" http://www.vintera.tv (16/11/18)
-- открывает подобные ссылки:
-- http://serv25.vintera.tv:8081/restream/rusk/playlist.m3u8?wmsAuthSign=c2Vyd1pbnV0ZXM9NDgw&tvin
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('&tvin$') then return end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
 	if not m_simpleTV.User.vinteraTV then
		m_simpleTV.User.vinteraTV = {}
	end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = 'error'
	local ua = 'Mozilla/5.0 (Linux; Android 5.1.1; Nexus 4 Build/LMY48T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.89 Mobile Safari/537.36'
	local session = m_simpleTV.Http.New(ua)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local retAdr = inAdr:gsub('&tvin$', '')
	if m_simpleTV.User.vinteraTV.token then
		retAdr = retAdr:gsub('wmsAuthSign=.+', 'wmsAuthSign=' .. m_simpleTV.User.vinteraTV.token)
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc == 200 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.Control.CurrentAdress = retAdr .. '$OPT:http-user-agent=' .. ua
	 	 return
		end
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL3htbC52aW50ZXJhLnR2L2FuZHJvaWRfdjA1MTcvaW50ZXJuZXR0di54bWw=')})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	m_simpleTV.User.vinteraTV.token = answer:match('wmsAuthSign=(.-)</')
		if not m_simpleTV.User.vinteraTV.token then return end
	retAdr = retAdr:gsub('wmsAuthSign=.+', 'wmsAuthSign=' .. m_simpleTV.User.vinteraTV.token) .. '$OPT:http-user-agent=' .. ua
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')