-- видеоскрипт для видеобазы "Collaps" https://collaps.org (18/4/20)
-- открывает подобные ссылки:
-- https://api1571722975.delivembed.cc/embed/movie/10517
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://api%d+%..-/embed/movie/%d+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://api%d+%..-/embed/kp/%d+')
			and not m_simpleTV.Control.CurrentAddress:match('^%$collaps')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'json'
	if inAdr:match('^%$collaps') or not inAdr:match('&kinopoisk') then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3945.79 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.collaps then
		m_simpleTV.User.collaps = {}
	end
	local title
	local refer = 'https://zombie-film.com/'
	local host = inAdr:match('https?://.-/')
	if m_simpleTV.User.collaps.TabTitle then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.collaps.title .. ' - ' .. m_simpleTV.User.collaps.TabTitle[index].Name
		end
	end
	local function collapsIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('collaps_qlty') or 5000)
		local index = #t
			for i = 1, #t do
				if t[i].qlty >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].qlty > lastQuality then
				index = index - 1
			end
		end
	 return index
	end
	local function GetcollapsAdr(url)
		local t, i = {}, 1
		local qlty, adr
			for qlty, adr in url:gmatch('"(%d+)":"(https?://.-)"') do
				t[i] = {}
				t[i].Address = adr
				t[i].qlty = qlty
				i = i + 1
			end
			if i == 1 then return end
			for _, v in pairs(t) do
				v.qlty = tonumber(v.qlty)
				if v.qlty > 0 and v.qlty <= 180 then
					v.qlty = 144
				elseif v.qlty > 180 and v.qlty <= 300 then
					v.qlty = 240
				elseif v.qlty > 300 and v.qlty <= 400 then
					v.qlty = 360
				elseif v.qlty > 400 and v.qlty <= 500 then
					v.qlty = 480
				elseif v.qlty > 500 and v.qlty <= 780 then
					v.qlty = 720
				elseif v.qlty > 780 and v.qlty <= 1200 then
					v.qlty = 1080
				elseif v.qlty > 1200 and v.qlty <= 1500 then
					v.qlty = 1444
				elseif v.qlty > 1500 and v.qlty <= 2800 then
					v.qlty = 2160
				elseif v.qlty > 2800 and v.qlty <= 4500 then
					v.qlty = 4320
				end
				v.Name = v.qlty .. 'p'
			end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		for i = 1, #t do
			t[i].Id = i
			t[i].Address = t[i].Address .. '$OPT:NO-STIMESHIFT$OPT:http-referrer=' .. refer
		end
		m_simpleTV.User.collaps.Tab = t
		local index = collapsIndex(t)
	 return t[index].Address
	end
	function Qlty_collaps()
		local t = m_simpleTV.User.collaps.Tab
			if not t or #t == 0 then return end
		m_simpleTV.Control.ExecuteAction(37)
		local index = collapsIndex(t)
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 1 + 4)
		if ret == 1 then
			m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
			m_simpleTV.Config.SetValue('collaps_qlty', t[id].qlty)
		end
	end
	local function play(Adr, title)
		local retAdr = GetcollapsAdr(Adr)
		m_simpleTV.Http.Close(session)
			if not retAdr then
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
			 return
			end
		if m_simpleTV.Control.CurrentTitle_UTF8 then
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		end
		m_simpleTV.OSD.ShowMessageT({text = title, color = ARGB(255, 155, 155, 255), showTime = 1000 * 5, id = 'channelName'})
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	end
		if inAdr:match('^%$collaps') then
			play(inAdr, title)
		 return
		end
	inAdr = inAdr:gsub('&kinopoisk', ''):gsub('buildplayer%.com', 'iframecdn.club')
	m_simpleTV.User.collaps.TabTitle = nil
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'Referer: ' .. refer})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.OSD.ShowMessageT({text = 'collaps ошибка[1]-' .. rc, color = ARGB(255, 255, 0, 0), showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	local season_title = ''
	local seson = ''
	title = m_simpleTV.Control.CurrentTitle_UTF8 or 'Collaps'
	m_simpleTV.Control.SetTitle(title)
	local seasons = answer:match('franchise:%s*(%d+)')
	if seasons then
		inAdr = host .. 'contents/season/by-franchise/?id=' .. seasons
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'Referer: ' .. refer})
			if rc ~= 200 then return end
		answer = answer:gsub('(%[%])', '"nil"')
		local tab = json.decode(answer)
			if not tab then return end
		local t, i = {}, 1
			while true do
					if not tab[i] then break end
				t[i] = {}
				t[i].Id = i
				t[i].Name = tab[i].season .. ' сезон'
				t[i].forSort = tab[i].season
				t[i].Address = tab[i].id
				i = i + 1
			end
			if i == 1 then return end
		if i > 2 then
			table.sort(t, function(a, b) return a.forSort < b.forSort end)
			for i = 1, #t do
				t[i].Id = i
			end
			t.ExtParams = {FilterType = 2}
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете сезон - ' .. title, 0, t, 5000, 1)
			if not id then
				id = 1
			end
		 	seson = t[id].Address
			season_title = ' (' .. t[id].Name .. ')'
		else
			seson = t[1].Address
			local ses = t[1].Name:match('%d+') or '0'
			if tonumber(ses) > 1 then
				season_title = ' (' .. t[1].Name .. ')'
			end
		end
	end
	local episodes = answer:match('seasonId:%s*(%d+)')
	if episodes then
		inAdr = host .. 'contents/video/by-season/?id=' .. seson
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'Referer: ' .. refer})
			if rc ~= 200 then return end
		answer = answer:gsub('(%[%])', '"nil"')
		local tab = json.decode(answer)
			if not tab then return end
		local t, i = {}, 1
		local Adr, name, poster
			for w in answer:gmatch('"id":.-"blocked"') do
				Adr = w:match('"urlQuality":{(.-)}')
				name = w:match('"episode":"(%d+)')
					if not Adr or not name then break end
				t[i] = {}
				t[i].Id = i
				t[i].Name = name .. ' серия'
				t[i].Address = '$collaps' .. Adr
				poster = w:match('"small":"(.-)"')
				if poster and poster:match('%.jpg') then
					t[i].InfoPanelName = title
					t[i].InfoPanelTitle = w:match('"name":"(.-)",') or t[i].Name
					t[i].InfoPanelShowTime = 5000
					t[i].InfoPanelLogo = poster
				end
				i = i + 1
			end
			if i == 1 then return end
		m_simpleTV.User.collaps.TabTitle = t
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_collaps()'}
		local p = 0
		if i == 2 then
			p = 32 + 128
		end
		t.ExtParams = {FilterType = 2}
		title = title .. season_title
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000, p)
		if not id then
			id = 1
		end
		inAdr = t[id].Address
		m_simpleTV.User.collaps.title = title
		title = title .. ' - ' .. m_simpleTV.User.collaps.TabTitle[1].Name
	else
		inAdr = answer:match('hlsList:%s*{(.-)}')
			if not inAdr then
				m_simpleTV.Http.Close(session)
				m_simpleTV.OSD.ShowMessageT({text = 'collaps ошибка[3]', color = ARGB(255, 155, 255, 155), showTime = 1000 * 5, id = 'channelName'})
			 return
			end
		title = answer:match('title:%s*"(.-)",') or 'Collaps'
		title = title:gsub('\\u0026', '&')
		local t1 = {}
		t1[1] = {}
		t1[1].Id = 1
		t1[1].Name = title
		t1[1].Address = inAdr
		t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_collaps()'}
		t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		m_simpleTV.OSD.ShowSelect_UTF8('Collaps', 0, t1, 5000, 64+32+128)
	end
	play(inAdr, title)