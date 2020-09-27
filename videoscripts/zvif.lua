-- видеоскрипт "zvif" [псевдо тв] https://zvif.ucoz.com (26/3/20)
-- необходим скрапер TVS: psevdotv_pls
-- необходимы скрипты: ok
-- открывает ссылку:
-- zvif
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^zvif') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
		if m_simpleTV.Control.ChannelID == 268435455 then
			m_simpleTV.Control.ChangeChannelLogo('https://sun9-19.userapi.com/c853520/v853520736/39771/kknA9bQ9jRA.jpg', m_simpleTV.Control.ChannelID)
		end
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'zvif ошибка: ' .. str, showTime = 5000, color = ARGB(255, 255, 0, 0), id = 'channelName'})
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
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36')
		if not session then
			showError('0')
		 return
		end
	local pls = 'http://zvif.ucoz.com/belomor4.txt' .. '?rand=' .. math.random()
	local header = 'Zvif TV 👺'
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