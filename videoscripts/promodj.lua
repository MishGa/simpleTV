-- видеоскрипт для сайта http://promodj.com (27/12/19)
-- открывает подобные ссылки:
-- http://promodj.com/pdjlive/videos/3758390/Timo_Mass_Santos_Mutant_Clan_PDJTV_HTC_DAR
-- http://promodj.com/tv/pdjlive/15017/Sergey_Sanchez_Epizode_official_afterparty
-- http://promodj.com/144330155140/tracks/6927648/DJ_Jey_Welcome_To_The_Uzbekistan
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAdress:match('^https?://promodj%.com') then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local logo = 'http://cdn.promodj.com/legacy/i/logo_2x_white.png'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function unescape_html(str)
		str = str:gsub('&nbsp;', ' ')
		str = str:gsub('&rsquo;', 'e')
		str = str:gsub('&eacute;', "'")
		str = str:gsub('&#039;', "'")
		str = str:gsub('&ndash;', "-")
		str = str:gsub('&#8217;', "'")
		str = str:gsub('&raquo;', '"')
		str = str:gsub('&laquo;', '"')
		str = str:gsub('&lt;', '<')
		str = str:gsub('&gt;', '>')
		str = str:gsub('&quot;', '"')
		str = str:gsub('&apos;', "'")
		str = str:gsub('&#(%d+);', function(n) return string.char(n) end)
		str = str:gsub('&#x(%d+);', function(n) return string.char(tonumber(n, 16)) end)
		str = str:gsub('&amp;', '&') -- Be sure to do this after all others
	 return str
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('http[^\'"<>]+%.mp4') or answer:match('http[^\'"<>]+%.m3u8') or answer:match('href="(http[^\'"<>]+%.mp3)')
		if not retAdr then return end
	local title = answer:match('<title>([^<]+)') or 'promodj'
	title = unescape_html(title)
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	logo = answer:match('"og:image" content="([^"]+)') or logo
	m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
	retAdr = retAdr:gsub('\\\\\\', '\\'):gsub('\\/', '/')
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')