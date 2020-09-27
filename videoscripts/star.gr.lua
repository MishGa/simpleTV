-- видеоскрипт для сайта https://www.star.gr (13/2/20)
-- открывает подобные ссылки:
-- https://www.star.gr/video/masterchef=489739
-- https://www.star.gr/tv/live-stream/
-- https://www.star.gr/tv/psychagogia/sti-folia-ton-kou-kou/i-farsa-tou-koutsopoulou-stous-kou-kou-to-flert-sti-marilou/
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAdress:match('^https?://www%.star%.gr') then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://www.star.gr/tv/Content/Media/logo.png', UseLogo = 1, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'Star.gr ένα λάθος: ' .. str, showTime = 8000, color = ARGB(255, 255, 0, 0), id = 'channelName'})
	end
	local function unescape_html(str)
		str = str:gsub('&#171;', '«')
		str = str:gsub('&#187;', '»')
		str = str:gsub('&#39;', '\'')
		str = str:gsub('&ndash;', '-')
		str = str:gsub('&#8217;', '\'')
		str = str:gsub('&raquo;', '"')
		str = str:gsub('&laquo;', '"')
		str = str:gsub('&lt;', '<')
		str = str:gsub('&gt;', '>')
		str = str:gsub('&quot;', '"')
		str = str:gsub('&apos;', '\'')
		str = str:gsub('&#(%d+);', function(n) return string.char(n) end)
		str = str:gsub('&#x(%d+);', function(n) return string.char(tonumber(n, 16)) end)
		str = str:gsub('&amp;', '&')
	 return str
	end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/79.0.2785.143 Safari/537.36')
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			showError('2')
			m_simpleTV.Http.Close(session)
		 return
		end
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local retAdr = answer:match('https?://[^\'"<>]+%.m3u8[^<>\'"]*')
		if not retAdr then
			showError('3')
		 return
		end
	local title = answer:match('"og:title" content="([^"]+)')
				or answer:match('"name":%s*"([^"]+)')
				or answer:match('\'Publisher Name\':%s*\'([^\']+)')
				or 'Star.gr'
	if m_simpleTV.Control.MainMode == 0 then
		title = unescape_html(title)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
		local poster = answer:match('"twitter:image" content="([^"]+)')
					or answer:match('"thumbnailUrl":%s*"([^"]+)')
					or answer:match('\'Publisher Logo\':%s*\'([^\']+)')
					or 'https://scdn.star.gr/images/news-logo.png'
		poster = poster:gsub('^/', 'https://www.star.gr/tv/')
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then
			showError('4')
		 return
		end
	m_simpleTV.Http.Close(session)
	local i, t0 = 1, {}
	local name, adr
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-%.m3u8)') do
			adr = w:match('\n(.-%.m3u8)')
			name = w:match('RESOLUTION=%d+x(%d+)')
				if not adr or not name then break end
			t0[i] = {}
			t0[i].Id = tonumber(name)
			t0[i].Name = name .. 'p'
			t0[i].Address = adr
			i = i + 1
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		 return
		end
	table.sort(t0, function(a, b) return a.Id < b.Id end)
	local hash, t = {}, {}
		for i = 1, #t0 do
			if not hash[t0[i].Name] then
				t[#t + 1] = t0[i]
				hash[t0[i].Name] = true
			end
		end
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('starGr_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ πάντα ψηλά'
		t[#t].Address = t[#t - 1].Address
		index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].Id > lastQuality then
				index = index - 1
			end
		end
		if m_simpleTV.Control.MainMode == 0 then
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'starGrSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Ποιότητα', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	function starGrSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('starGr_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')