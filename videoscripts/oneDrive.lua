-- видеоскрипт для сайта https://onedrive.live.com (22/12/19)
-- открывает подобные ссылки:
-- https://1drv.ms/v/s!AlrLrycbTQ1ayqIwTZxx-Y2aK8_paA
-- https://onedrive.live.com/embed?cid=FA476CAFF1A7E75C&resid=FA476CAFF1A7E75C%21122&authkey=AN_axXpcOy7Zfl8
-- https://onedrive.live.com/download?cid=38094E90A5950E99&resid=38094E90A5950E99%21813&authkey=AHwM_2Px2yHCBkc
-- https://onedrive.live.com/redir?resid=A232DB046EA25AEC!180&authkey=!AAiEtii-81s5EG8&ithint=video%2c.mp4
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAdress:match('^https?://1drv%.ms')
			and not m_simpleTV.Control.CurrentAdress:match('^https?://onedrive%.live%.com')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAdress
	local logo = 'https://cdn.iconscout.com/icon/free/png-256/onedrive-6-569266.png'
	m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local function unescape_html(str)
		str = str:gsub('&#8217;', "'")
		str = str:gsub('&#39;', "'")
		str = str:gsub('&raquo;', '"')
		str = str:gsub('&laquo;', '"')
		str = str:gsub('&lt;', '<')
		str = str:gsub('&gt;', '>')
		str = str:gsub('&quot;', '"')
		str = str:gsub('&apos;', "'")
		str = str:gsub('&#(%d+);', function(n) return string.char(n) end)
		str = str:gsub('&#x(%d+);', function(n) return string.char(tonumber(n, 16)) end)
		str = str:gsub('&amp;', '&') -- в самом конце
	 return str
	end
	if inAdr:match('^https?://1drv%.ms') then
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		inAdr = answer:match('url=([^"]+)')
			if not inAdr then return end
	end
	local retAdr = unescape_html(inAdr)
	retAdr = retAdr:gsub('/embed', '/')
	retAdr = retAdr:gsub('/redir', '/')
	retAdr = retAdr:gsub('&id=', '&resid=')
	retAdr = retAdr:gsub('%?id=', '?resid=')
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	if not retAdr:match('live%.com/download') then
		retAdr = retAdr:gsub('live%.com/', 'live.com/download')
	end
	m_simpleTV.Control.CurrentAdress = retAdr
	m_simpleTV.Control.CurrentTitle_UTF8 = 'OneDrive'
	m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
-- debug_in_file(retAdr .. '\n')