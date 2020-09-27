-- видеоскрипт для сайта http://ok-tv.org (29/6/20)
-- открывает подобные ссылки:
-- http://ok-tv.org/channels/179-kinoseriya.html
-- ## прокси ##
local proxy = 'https://proxy-nossl.antizapret.prostovpn.org:29976'
-- '' - нет
--  'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://ok%-tv%.org') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3538.102 Safari/537.36', proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local url = answer:match('id="vkl".-<iframe.-src="([^"]+)')
		if not url then return end
	if proxy ~= '' then
		m_simpleTV.Http.Close(session)
		session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3538.102 Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: ' .. inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local retAdr = answer:match('http[^\'"<>]+%.m3u8[^<>\'"]*')
	if not retAdr then
		local adr = answer:match('<iframe.-src="([^"]+)')
			if not adr then return end
		if adr:match('sportbox%.ws') and proxy ~= '' then
			m_simpleTV.Http.Close(session)
			session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3538.102 Safari/537.36', proxy, false)
				if not session then return end
			m_simpleTV.Http.SetTimeout(session, 8000)
		end
		local rc, answer = m_simpleTV.Http.Request(session, {url = adr, headers = 'Referer: ' .. url})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		retAdr = answer:match('http[^\'"<>]+%.m3u8[^<>\'"]*')
			if not retAdr then return end
		if proxy ~= '' then
			retAdr = retAdr .. '$OPT:http-proxy=' .. proxy
		end
	end
	m_simpleTV.Http.Close(session)
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')