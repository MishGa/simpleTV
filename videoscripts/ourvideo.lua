-- видеоскрипт для сайта https://ourvideo.ru (10/8/18)
-- открывает подобные ссылки:
-- https://ourvideo.ru/player/embed/html/oJXV-ut3cpXxY80nf72hCxP1LGaFfDoXNorO9KvKwIxk1
-- https://www.myvi.xyz/embed/9f6nwxa6b6sriee79hxe4txf7w
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('https?://ourvideo%.ru/player/embed/') and not inAdr:match('https?://www%.myvi%.xyz/embed/') then return end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/68.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('Player%("v=(.-)"')
		if not retAdr then return end
	retAdr = unescape3(retAdr)
	retAdr = url_decode(retAdr)
	retAdr = retAdr:match('.-video/mp4') or retAdr:match('.-=//') or retAdr:match('.-video/flv')
		if not retAdr then return end
	m_simpleTV.Control.CurrentAdress = retAdr .. '$OPT:POSITIONTOCONTINUE=0'
-- debug_in_file(retAdr .. '\n')