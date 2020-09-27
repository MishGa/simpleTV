-- видеоскрипт для сайта https://www.dancetelevision.net (11/8/19)
-- необходимы скрипты: soundcloud
-- открывает подобные ссылки:
-- https://www.dancetelevision.net/house-floor/videos/creators/54/house-junkies-going-deep-dj-al-p-2-tech-house-music-dj-mix-video
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('^https?://www%.dancetelevision%.net') then return end
	m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 3, Once = 1})
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.87 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then  return end
	local retAdr = answer:match('[^\'\"<>]+%.mp4[^<>\'\"]*')
				or answer:match('[^\'\"<>]+api%.soundcloud%.com[^<>\'\"]+')
		if not retAdr then return end
		if retAdr:match('soundcloud%.com') then
			retAdr = retAdr:gsub('&amp;', '&')
			retAdr = retAdr:gsub('&#x3D;', '=')
			retAdr = retAdr:gsub('^//', 'https://')
			m_simpleTV.Control.ChangeAdress = 'No'
			m_simpleTV.Control.CurrentAdress = retAdr
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
	local title = answer:match('<title>(.-)</title>') or 'dancetelevision'
	if m_simpleTV.Control.CurrentTitle_UTF8 then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	if m_simpleTV.Common.GetVlcVersion() > 3000 then
		retAdr = retAdr .. '$OPT:no-gnutls-system-trust'
	end
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')