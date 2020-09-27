-- видеоскрипт для сайта https://tet.tv (25/12/19)
-- открывает подобные ссылки:
-- https://1plus1.video/tvguide/plusplus/online
-- http://ovva.tv/video/embed/e2dJ6euG?&pl=1
-- https://1plus1.video/video/embed/i21ZkgCj?tl=true&l=ru
-- https://tet.tv/ru/1plus1video/skazki-u
-- https://1plus1.video/ru/video/embed/VR67jYuA
-- https://1plus1.ua/ru/1plus1video/sekretnye-materialy
-- https://2plus2.ua/1plus1video/zateryannyj-mir
-- https://plus-plus.tv/ru/1plus1video/ce-nashe-i-ce-tvoe
-- https://1plus1.ua/vecir-premer-z-katerinou-osadcou/novyny/monatik-i-katerina-kuhar-vikonali-spokuslivij-tanec-foto
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('^https?://ovva%.tv')
			and not inAdr:match('^https?://tet%.tv')
			and not inAdr:match('^https?://1plus1%.video')
			and not inAdr:match('^https?://1plus1%.ua')
			and not inAdr:match('^https?://2plus2%.ua')
			and not inAdr:match('^https?://plus%-plus%.tv')
		then
		 return
		end
		if inAdr:match('smil/') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 3, Once = 1})
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	inAdr = inAdr:gsub('tl=.-$', '&pl=1')
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/78.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
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
	if inAdr:match('&pl=') then
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		inAdr = answer:match('"canonical" href="(.-)"') or inAdr
	end
	if not inAdr:match('/embed/') then
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local title = answer:match('<title>(.-)</title>') or 'ovvatv'
		title = title:gsub('смотреть онлай.+', ''):gsub('^Смотреть ', ''):gsub('на 1%+1.+', ''):gsub('дивитись онлай.+', ''):gsub('дивитися онлай.+', '')
		local seaslist = answer:match('class="seasons%-select".-</select>')
		if seaslist then
			local t, i = {}, 1
			local name, adr
				for ww in seaslist:gmatch('<option.-</option>') do
					name = ww:match('>(.-)<')
					adr = ww:match('value="(.-)"')
						if not name or not adr then break end
					t[i] = {}
					t[i].Id = i
					t[i].Adress = adr
					t[i].Name = unescape_html(name)
					i = i + 1
				end
				if i == 1 then return end
			if i > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title .. ' - выберете сезон', 0, t, 5000, 1)
				if not id then id = 1 end
				inAdr = t[id].Adress
			else
				inAdr = t[1].Adress
			end
			rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
				 return
				end
		end
		local serialist = answer:match('<div class="playlist%-parent".-<div class="video%-recomm"')
		if serialist then
			local t1, i = {}, 1
			local name, adr
			for name, adr in serialist:gmatch('title="(.-)".-data%-card%-id="(.-)"') do
				t1[i] = {}
				t1[i].Id = i
				t1[i].Adress = 'https://ovva.tv/video/embed/' .. adr
				t1[i].Name = unescape_html(name)
				i = i + 1
			end
				if i == 1 then return end
			if i > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t1, 5000)
				if not id then id = 1 end
				inAdr = t1[id].Adress
			else
				inAdr = t1[1].Adress
			end
		else
			inAdr = answer:match('class="iframe%-container".-<iframe.-src="(.-)"') or answer:match('<iframe src="(.-)"')
				if not inAdr then return end
		end
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local title0 = answer:match('<title>(.-)</title>')
	local answerJS = answer:match('"ovva%-player","(.-)"')
		if not answerJS then
			local err_live = answer:match('live%-error%-title">(.-)<')
			if err_live then
				err_live = unescape_html(err_live)
			end
			m_simpleTV.OSD.ShowMessageT({text = err_live or 'Видео недоступно', showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	answerJS = decode64(answerJS)
	local title = answerJS:match('"title":"(.-)"') or 'ovvatv'
	title = unescape3(title)
	if title0 and answerJS:match('"live":true') then
		title0 = title0:gsub('смотреть онлай.+', ''):gsub('^Смотреть ', ''):gsub('на 1%+1.+', ''):gsub('дивитись онлай.+', ''):gsub('дивитися онлай.+', '')
		title0 = title0:gsub('Онлайн трансляції спорту.+', 'Спорт')
		title = title0 .. '\n' .. title
	end
	answerJS = answerJS:gsub('\\/', '/')
	local balancer = answerJS:match('"balancer":"(.-)"')
		if not balancer then return end
	local refer = answerJS:match('{"url":"(.-)"') or inAdr
	rc, answer = m_simpleTV.Http.Request(session, {url = balancer, headers = 'Referer: ' .. refer})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('http.+')
		if not retAdr then return end
	if m_simpleTV.Control.CurrentTitle_UTF8 then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	m_simpleTV.OSD.ShowMessageT({text = title, color = ARGB(255, 155, 155, 255), showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Control.CurrentAdress = retAdr .. '$OPT:NO-STIMESHIFT'
-- debug_in_file(retAdr .. '\n')