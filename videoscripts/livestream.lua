-- видеоскрипт для сайта https://livestream.com (20/8/19)
-- открывает подобные ссылки:
-- https://livestream.com/accounts/2363281/live
-- https://livestream.com/accounts/1160789/Ferrari/videos/102503387
-- https://player-api.new.livestream.com/accounts/26619010/events/7987650/stream_info
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('^https?://livestream%.com')
			and not inAdr:match('^https?://player%-api%.new%.livestream%.com')
		then
		 return
		end
	m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 3, Once = 1})
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.87 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('"secure_m3u8_url":"(.-)"')
		if not retAdr then return end
	local title = answer:match('<title>(.-)</title>') or answer:match('"stream_title":"(.-)",') or 'livestream'
	title = title:gsub(' on Livestream$', '')
	if m_simpleTV.Control.CurrentTitle_UTF8 then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')