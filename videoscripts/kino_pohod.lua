-- видеоскрипт "Кинопоход!" [псевдо тв] https://yandex.ru (6/9/20)
-- Copyright © 2017-2020 Nexterr
-- необходим скрапер TVS: psevdotv_pls
-- необходимы скрипты: yandex
-- открывает ссылку:
-- kino_pohod
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^kino_pohod') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
		if m_simpleTV.Control.ChannelID == 268435455 then
			m_simpleTV.Control.ChangeChannelLogo('https://raw.githubusercontent.com/Nexterr/simpleTV.img/master/kino_pohod.png', m_simpleTV.Control.ChannelID)
		end
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'kino pohod ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then
			showError('0')
		 return
		end
	local pls = decode64('aHR0cHM6Ly9mcm9udGVuZC52aC55YW5kZXgucnUvZXBpc29kZXM/cGFyZW50X2lkPTRkZTc3M2U2MmMwN2ZlOTg4NzM1YTE3MzUzZmFhOTNkLDRhN2Q2ZGUxZjE1ZTZmYWViMDUwMzI1NTFlOTlkMmU4LDQ3MjVmNTg1OTBhY2FhMjQ5NDEwNGEwYjJhNGMxOGQ3LDQwZWQ2ZGJjNzNhMGEyZTZhMjY1YWQzOWY5ZmJmYTVmLDRmOTcwNzkwNGVkNTY5OGQ5N2E5NDhkZTBjMDFiZGI5LDQ0YmY2ODFiNjNlMzNiY2I5NWQyMDY3MWM0OWNiYWJkLDQ2NWI5YTNlZWVlMzRkYjY4NzA1ZTg0ZTBlN2Q2YWE2JmVuZF9kYXRlX19mcm9tPQ') .. os.time()
	local rc, answer = m_simpleTV.Http.Request(session, {url = pls})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('1')
		 return
		end
	require 'json'
	answer = answer:gsub('%[%]', '""')
	local t = json.decode(answer)
		if not t
			or not t.set
		then
		 return
		end
	local tab, i = {}, 1
		while true do
				if not t.set[i] then break end
			tab[i] = {}
			tab[i].Id = i
			tab[i].Name = t.set[i].title
			tab[i].Address = string.format('%s?&isPlst=true&fromScr=true', t.set[i].content_url:gsub('%?.-$', ''))
			i = i + 1
		end
		if i == 1 then
			showError('2')
		 return
		end
	tab.ExtParams = {}
	tab.ExtParams.Random = 1
	tab.ExtParams.PlayMode = 1
	tab.ExtParams.StopOnError = 0
	local plstIndex = math.random(#tab)
	m_simpleTV.OSD.ShowSelect_UTF8('Кинопоход! 🎞️', plstIndex - 1, tab, 0, 64 + 256)
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.CurrentAddress = tab[plstIndex].Address
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(tab[plstIndex].Address .. '\n')