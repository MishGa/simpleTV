-- видеоскрипт для сайта http://riperam.org (2/2/19)
-- необходим Acestream
-- открывает подобные ссылки:
-- http://riperam.org/download/file.php?id=1144684&adkeys=1
-- http://riperam.org/zarubejnie-do2000/vedmi-the-witches-t229809.html
------------------------------------------------------------------------------------------
local proxy = '' -- прокси: '' - нет; например 'http://proxy.antizapret.prostovpn.org:3128'
------------------------------------------------------------------------------------------
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('https?://riperam%.org') and not inAdr:match('riperam_id%d+%.torrent') then return end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
		if inAdr:match('riperam_id%d+%.torrent') then
			if not inAdr:match('^torrent') then
				inAdr = 'torrent://' .. inAdr
				riperam_logo = nil
			end
			m_simpleTV.Control.CurrentAddress = inAdr
			if riperam_logo then m_simpleTV.Control.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = riperam_logo, TypeBackColor = 0, UseLogo = 3, Once = 1}) end
			if m_simpleTV.Control.CurrentTitle_UTF8 then m_simpleTV.Control.CurrentTitle_UTF8 = 'riperam' end
		 return
		end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/71.0.2785.143 Safari/537.36', proxy, true)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local id = inAdr:match('file%.php%?id=(%d+)')
	local host = inAdr:match('https?://.-/')
	riperam_logo = nil
	if not id then
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				m_simpleTV.OSD.ShowMessageT({text = 'riperam ошибка[1]-' .. rc, color = 0xff9b80ff, showTime = 1000 * 5, id = 'channelName'})
			 return
			end
		id = answer:match('/download/file%.php%?id=(%d+)')
		riperam_logo = answer:match('rel="prettyPhotoPosters%[.-%]"><img src="(.-)"')
		if riperam_logo then m_simpleTV.Control.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = riperam_logo, TypeBackColor = 0, UseLogo = 3, Once = 1}) end
	end
		if not id then
			m_simpleTV.OSD.ShowMessageT({text = 'riperam ошибка[2]', color = 0xff9b80ff, showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	local retAdr = host .. 'download/file.php?id=' .. id
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, filename = 'riperam_id' .. id .. '.torrent', writeinfile = true})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.OSD.ShowMessageT({text = 'riperam ошибка[3]-' .. rc, color = 0xff9b80ff, showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	if m_simpleTV.Control.CurrentTitle_UTF8 then m_simpleTV.Control.CurrentTitle_UTF8 = 'riperam' end
	m_simpleTV.Control.CurrentAddress = 'torrent://' .. answer
-- debug_in_file(retAdr .. '\n')