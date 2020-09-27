-- видеоскрипт "Море фильмов" [псевдо тв] https://more.tv (6/9/20)
-- Copyright © 2017-2020 Nexterr
-- необходим скрапер TVS: psevdotv_pls
-- необходимы скрипты: more.tv
-- открывает ссылку:
-- more_film
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^more_film') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
		if m_simpleTV.Control.ChannelID == 268435455 then
			m_simpleTV.Control.ChangeChannelLogo('https://raw.githubusercontent.com/Nexterr/simpleTV.img/master/more_film.png', m_simpleTV.Control.ChannelID)
		end
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'more film ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then
			showError('0')
		 return
		end
	local pls = decode64('aHR0cHM6Ly9tb3JlLnR2L2FwaS92Mi93ZWIvcHJvamVjdHM/ZmlsdGVyW2NhdGVnb3J5XVswXT1NT1ZJRSZmaWx0ZXJbc3Vic2NyaXB0aW9uVHlwZV1bMF09RlJFRSZmaWx0ZXJbaXNTZW9TdWl0YWJsZV09MSZzb3J0WzBdPS1pc0FjdGl2ZSZzb3J0WzFdPS1pZCZwYWdlW29mZnNldF09MCZmaWx0ZXJbdHlwZV09TU9WSUUmZmlsdGVyW2lzQWN0aXZlXT0xJnBhZ2VbbGltaXRdPTIwMDA')
	local rc, answer = m_simpleTV.Http.Request(session, {url = pls, headers = 'content-type: application/json\nReferer: https://more.tv/'})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('1')
		 return
		end
	require 'json'
	answer = answer:gsub('%[%]', '""')
	local t = json.decode(answer)
		if not t
			or not t.data
			or not t.data.projects
		then
			showError('2')
		 return
		end
	local tab, i = {}, 1
		while t.data.projects[i] do
			tab[i] = {}
			tab[i].Id = i
			tab[i].Address = string.format('https://more.tv%s?&isPlst=true&fromScr=true', t.data.projects[i].canonicalUrl)
			i = i + 1
		end
		if i == 1 then
			showError('3')
		 return
		end
	tab.ExtParams = {}
	tab.ExtParams.Random = 1
	tab.ExtParams.PlayMode = 1
	tab.ExtParams.StopOnError = 0
	local plstIndex = math.random(#tab)
	m_simpleTV.OSD.ShowSelect_UTF8('Море фильмов 🎞️', plstIndex - 1, tab, 0, 64 + 256)
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.CurrentAddress = tab[plstIndex].Address
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(tab[plstIndex].Address .. '\n')