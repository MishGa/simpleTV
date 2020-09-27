-- видеоскрипт для сайта http://cccp-film.ru (10/8/18)
-- необходимы скрипты: vk, youtube, pladform
-- открывает подобные ссылки:
-- http://cccp-film.ru/video/sovetskie-filmy/yekipazh-1979.html
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
	if not inAdr:match('https?://cccp%-film%.ru') then return end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/68.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.OSD.ShowMessage_UTF8('cccp_film ошибка[1]-' .. rc, 255, 5)
		 return
		end
	local id = answer:match("movie_id[%s]?=[%s]?'(.-)'")
		if not id then
			m_simpleTV.Http.Close(session)
			m_simpleTV.OSD.ShowMessage_UTF8('cccp_film ошибка[2]', 255, 5)
		 return
		end
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'http://cccp-film.ru/components/video/ajax/get_movie_code.php?id=' .. id .. '&autopay=0&skip_ads=1'})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.OSD.ShowMessage_UTF8('cccp_film ошибка[3]-' .. rc, 255, 5)
		 return
		end
	local retAdr = answer:match('iframe src="(.-)"') or answer:match('file":"(.-)"') or answer:match("videoId: '(.-)'") or answer:match("iframe src='(.-)'")
		if not retAdr then
			m_simpleTV.OSD.ShowMessage_UTF8('cccp_film ошибка[4]', 255, 5)
		 return
		end
	if answer:match('videoId') and answer:match('youtube') then	retAdr = 'https://www.youtube.com/embed/' .. retAdr end
	retAdr = retAdr:gsub('^//', 'https://'):gsub('\\/', '/')
	m_simpleTV.Control.ChangeAdress = 'No'
	m_simpleTV.Control.CurrentAdress = retAdr
	dofile(m_simpleTV.MainScriptDir .. "user\\video\\video.lua")
-- debug_in_file(retAdr .. '\n')