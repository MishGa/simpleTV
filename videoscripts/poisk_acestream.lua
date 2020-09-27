-- видеоскрипт для поиска трансляций ACEStream http://acestream.org (8/6/19)
-- необходим Acestream
-- искать через команду меню "Открыть URL" (Ctrl+N)
-- использовать префикс "+"
-- открывает подобные запросы: + матч
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('^%+') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', color = ARGB(0, 0, 0, 0), showTime = 1000 * 1, id = 'channelName'})
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/73.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	inAdr = inAdr:gsub('^%+', '')
	inAdr = m_simpleTV.Common.multiByteToUTF8(inAdr)
	local url = 'https://search.acestream.net/?method=search&api_version=1.0&api_key=test_api_key&query=' .. escape(inAdr)
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.OSD.ShowMessageT({text = 'poisk_acestream ошибка[1]-' .. rc, color = ARGB(255, 255, 0, 0), showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	answer = answer:gsub('(%[%])', '"nil"'):gsub(string.char(239, 187, 191), ''):gsub('\\', '\\\\'):gsub('\\"', '\\\\"'):gsub('\\/', '/')
	require 'json'
	local tab = json.decode(answer)
		if not tab or not tab.results then
			m_simpleTV.OSD.ShowMessageT({text = 'poisk_acestream ошибка[2]', color = ARGB(255, 255, 0, 0), showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	local t, i, h = {}, 1, 1
		while true do
				if not tab.results[h] then break end
			if (tab.results[h].availability or 0) > 0.5
				and (os.time() - (tab.results[h].availability_updated_at or 0)) < (3 * 60 * 60)
			then
				t[i] = {}
				t[i].Id = i
				t[i].Name = unescape3(tab.results[h].name)
				t[i].Adress = 'torrent://INFOHASH=' .. tab.results[h].infohash
				i = i + 1
			end
			h = h + 1
		end
		if i == 1 then
			m_simpleTV.OSD.ShowMessageT({text = 'не найдено\n\npoisk_acestream ошибка[3]', color = ARGB(255, 255, 0, 0), showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	m_simpleTV.Control.ExecuteAction(11)
	local ret, id = m_simpleTV.OSD.ShowSelect_UTF8(inAdr .. ' - поиск ACEStream', 0, t, 0)
		if not id then return end
	if ret == 1 then
		m_simpleTV.Control.CurrentAdress = t[id].Adress
	end
-- debug_in_file(t[id].Adress .. '\n')