-- видеоскрипт для сайта https://tvzvezda.ru (10/8/18)
-- необходимы скрипты: youtube
-- открывает подобные ссылки:
-- https://tvzvezda.ru/schedule/filmsonline/content/201712191710-rv1c.htm/
-----------------------------------------------------------------------------------------
local demux = 1 -- демуксер: 0 - не менять; 1 - использовать avcodec
-----------------------------------------------------------------------------------------
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('https?://tvzvezda%.ru') then return end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/68.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('http[^\'\"<>]+%.mp4') or answer:match('http[^\'\"<>]+watch%?v=[^<>\'\"]+') or answer:match('http[^\'\"<>]+/embed/[^<>\'\"]+')
		if not retAdr then return end
	local title = answer:match('<h1>(.-)</h1>') or 'tvzvezda'
	m_simpleTV.Control.CurrentTitle_UTF8 = title
		if retAdr:match('watch%?v=') or retAdr:match('/embed/') then
			m_simpleTV.Control.ChangeAdress = 'No'
			m_simpleTV.Control.CurrentAdress = retAdr:gsub('https?://youtube', 'https://www.youtube')
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
	if demux ~= 0 then retAdr = retAdr .. '$OPT:demux=avcodec' end
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')