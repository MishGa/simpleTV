-- видеоскрипт для сайта https://www.anilibria.tv (18/4/20)
-- необходимы скрипты: moonwalk, youtube
-- необходим Acestream
-- открывает подобные ссылки:
-- https://www.anilibria.tv/release/school-rumble.html
-- https://www.anilibria.tv/release/shuumatsu-nani-shitemasu-ka-isogashii-desu-ka-sukutte-moratte-ii-desu-ka.html
-- https://www.anilibria.tv/upload/torrents/264.torrent
-- прокси -------------------------------------------------------------------------------
local proxy = 'http://proxy-nossl.antizapret.prostovpn.org:29976'
-- '' - нет
-- 'http://proxy-nossl.antizapret.prostovpn.org:29976' - например
-- 'http://103.89.253.246:3128' - например
------------------------------------------------------------------------------------------
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://www%.anilibria%.tv')
			and not inAdr:match('^%$anilibria')
		then
		 return
		end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 3, Once = 1})
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local extopt = ''
	if proxy ~= '' then
		extopt = extopt .. '$OPT:http-proxy=' .. proxy
	end
		if inAdr:match('^%$anilibria') then
			local title
			if not anilibriaTitle then
				anilibriaTitle = ''
			end
			if anilibriaTable then
				local index = m_simpleTV.Control.GetMultiAddressIndex()
				if index then
					title = anilibriaTitle .. ' - ' .. anilibriaTable[index].Name
				end
			end
			if m_simpleTV.Control.CurrentTitle_UTF8 then
				m_simpleTV.Control.CurrentTitle_UTF8 = title
			end
			m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9bffff, showTime = 1000 * 5, id = "channelName"})
			m_simpleTV.Control.CurrentAddress = inAdr:gsub('%$anilibria', '') .. '$OPT:NO-STIMESHIFT' .. extopt
		 return
		end
	local timeout = 8000
	if proxy ~= '' then
		timeout = 20000
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.87 Safari/537.36', proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, timeout)
		if inAdr:match('%.torrent') then
			local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, writeinfile = true})
			m_simpleTV.Http.Close(session)
				if rc ~= 200 then return end
			local retAdr = 'torrent://' .. answer
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local title = answer:match('<title>(.-)</title>') or 'anilibria'
	if m_simpleTV.Control.CurrentTitle_UTF8 then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	local retAdr = answer:match('<div class="xplayer z%-fix" id="moonPlayer".-<iframe src="(.-)"')
		if retAdr then
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = retAdr:gsub('^//', 'http://'):gsub('%?.-$', '')
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
	answer = answer:match('file:(%[.-%]),')
		if not answer then return end
	answer = answer:gsub('%[%]', '"nil"')
	answer = answer:gsub('\'', '"')
	answer = answer:gsub('%?download=.-"', '"')
	answer = answer:gsub(' download:"', ' "download":"')
	answer = answer:gsub(',%]$', ']')
	require 'json'
	local tab = json.decode(answer)
		if not tab then return end
	local t, i = {}, 1
	local adr, name
		while true do
				if not tab[i] then break end
			t[i] = {}
			t[i].Id = i
			t[i].Name = tab[i].title
			t[i].Address = '$anilibria' .. tab[i].download
			i = i + 1
		end
		if i == 1 then return end
	t.ExtParams = {FilterType = 2}
	anilibriaTable = t
	anilibriaTitle = title
	if i > 2 then
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000)
		if not id then id = 1 end
		retAdr = t[id].Address
	else
		retAdr = t[1].Address
	end
	m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9bffff, showTime = 1000 * 5, id = "channelName"})
	retAdr = retAdr:gsub('%$anilibria', '') .. '$OPT:NO-STIMESHIFT' .. extopt
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')