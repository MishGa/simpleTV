-- видеоскрипт "m24" [псевдо тв] http://m24.do.am (6/9/20)
-- Copyright © 2017-2020 Nexterr
-- необходим скрапер TVS: psevdotv_pls
-- необходимы скрипты: youtube
-- открывает подобные ссылки:
-- m24_mtv
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^m24_') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
		if m_simpleTV.Control.ChannelID == 268435455 then
			m_simpleTV.Control.ChangeChannelLogo('https://raw.githubusercontent.com/Nexterr/simpleTV.img/master/m24.png', m_simpleTV.Control.ChannelID)
		end
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'imtv ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	function removeDuplicates(tbl)
		local timestamps, newTable = {}, {}
			for index, record in ipairs(tbl) do
				if not timestamps[record.Address] then
					timestamps[record.Address] = 1
					table.insert(newTable, record)
				end
			end
	 return newTable
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then
			showError('0')
		 return
		end
	local pls, header
	if inAdr:match('m24_mtv') then
		pls = 'http://imtv.at.ua/uppod/playlist_video110-334.txt'
		header = 'I\'MUSIC (М24) 🎵🎶'
	elseif inAdr:match('m24_oldtv') then
		pls = 'http://m24.do.am/_fr/0/old.txt'
		header = 'OLD (М24) 👴👵'
	elseif inAdr:match('m24_slowtv') then
		pls = 'http://m24.do.am/_fr/0/slow.txt'
		header = 'SLOW (М24) 🐢🐌'
	elseif inAdr:match('m24_blacktv') then
		pls = 'http://m24.do.am/_fr/0/black.txt'
		header = 'BLACK (М24) 🌚'
	elseif inAdr:match('m24_trancetv') then
		pls = 'http://m24.do.am/_fr/0/trance.txt'
		header = 'TRANCE (М24) ☠'
	elseif inAdr:match('m24_djlivetv') then
		pls = 'http://m24.do.am/_fr/0/livetrance.txt'
		header = 'DJ LIVE (М24) 🎤🎙'
	elseif inAdr:match('m24_dancetv') then
		pls = 'http://m24.do.am/_fr/0/dance.txt'
		header = 'DANCE (М24) 🕺💃'
	elseif inAdr:match('m24_rocktv') then
		pls = 'http://m24.do.am/_fr/0/rock.txt'
		header = 'ROCK (М24) 🎸'
	elseif inAdr:match('m24_hardtv') then
		pls = 'http://m24.do.am/_fr/0/hard.txt'
		header = 'HARD (М24) ⚡'
	elseif inAdr:match('m24_hottv') then
		pls = 'http://m24.do.am/_fr/0/hot.txt'
		header = 'HOT (М24) 🔥'
	elseif inAdr:match('m24_m24tv') then
		pls = 'http://m24.do.am/_fr/0/m24.txt'
		header = 'MUSIC24 (М24) 🎼'
	end
	pls = pls .. '?rand=' .. math.random()
	local rc, answer = m_simpleTV.Http.Request(session, {url = pls})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('1')
		 return
		end
	answer = answer:gsub('^.-"', '{"')
	require 'json'
	local t = json.decode(answer)
		if not t or not t.playlist then
			showError('2')
		 return
		end
	local tab, i = {}, 1
		while t.playlist[i] do
			tab[i] = {}
			tab[i].Id = i
			tab[i].Address = t.playlist[i].file .. '?&isPlst=true&fromScr=true'
			i = i + 1
		end
		if i == 1 then
			showError('3')
		 return
		end
	tab = removeDuplicates(tab)
	tab.ExtParams = {}
	tab.ExtParams.Random = 1
	tab.ExtParams.PlayMode = 1
	tab.ExtParams.StopOnError = 0
	local plstIndex = math.random(#tab)
	m_simpleTV.OSD.ShowSelect_UTF8(header, plstIndex - 1, tab, 0, 64 + 256)
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.CurrentAddress = tab[plstIndex].Address
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(tab[plstIndex].Address .. '\n')