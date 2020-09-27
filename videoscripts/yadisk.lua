-- видеоскрипт "Yandex disk" https://yadi.sk (16/10/18)
-- открывает подобные ссылки:
-- https://yadi.sk/d/CRjyJyqw3QUzTL
-- https://yadi.sk/mail/?hash=2Mdv%2BzjxB6SgzI61UqSE9GyWXaDpVWd4uTsWXWvwXv4%3D
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('https?://yadi%.sk/%w/') and not inAdr:match('https?://yadi%.sk/mail') then return end
	require 'json'
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/68.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	inAdr = inAdr:gsub('%s', '%%20')
	local retAdr, title, pubAdr, path
	local function CheckExt(name)
		local tt = {'%.txt', '%.cue', '%.log', '%.jpg', '%.png', '%.docx', '%.m3u', '%.xls', '%.xlsx', '%.accurip', '%.jpeg', '%.TXT'}
		for i, v in ipairs(tt) do
 			if string.match(name, v) then return true end
		end
	 return false
	end
	local function getAdr(pubAdr, path)
		local url = 'https://cloud-api.yandex.net:443/v1/disk/public/resources/download?public_key=' .. url_encode(pubAdr) .. '&path=' .. url_encode(path)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	 return answer:match('"href":"(.-)"')
	end
	local function getres(pubAdr, path)
		local url = 'https://cloud-api.yandex.net/v1/disk/public/resources?public_key=' .. url_encode(pubAdr) .. '&limit=100&path=' .. url_encode(path)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	 return answer
	end
	local function ge(inAdr)
		if inAdr:match('hash=') then
			pubAdr = inAdr:match('hash=(.+)')
			path = ''
			pubAdr = url_decode(pubAdr)
		else
			pubAdr = inAdr:match('(https?://yadi%.sk/.-/[A-Za-z0-9-_#$%^&*]*)')
			path = inAdr:match('https?://yadi%.sk/.-/[A-Za-z0-9-_#$%^&*]*(/.+)') or ''
			path = url_decode(path)
		end
		local answer = getres(pubAdr, path)
			if not answer then return end
		if not answer:match('_embedded') then
			if inAdr:match('hash=') then
				retAdr = answer:match('"file":"(.-)"')
			else
				local inAdr = m_simpleTV.Common.multiByteToUTF8(inAdr)
				pubAdr = inAdr:match('(https?://yadi%.sk/.-/.-/)') or inAdr:match('(https?://yadi%.sk/.-/.+)')
				path = inAdr:match('https?://yadi%.sk/.-/[A-Za-z0-9-_#$%^&*]*(/.+)') or ''
			end
			path = url_decode(path)
			retAdr = getAdr(pubAdr, path)
		 return	retAdr
	 	end
		if answer:match('_embedded') then
			local t = json.decode(answer:gsub('(%[%])', '"nil"'))
			if t == nil then return end
			local a, j = {}, 1
				while true do
						if t._embedded.items[j] == nil then break end
					a[j] = {}
					a[j].Id = j
					a[j].Name = t._embedded.items[j].name
					a[j].Adress = t._embedded.items[j].path
					a[j].mtype = t._embedded.items[j].media_type
					a[j].ftype = t._embedded.items[j].type
					j = j + 1
				end
			local ret, i, u = {}, 1, 1
				for _, v in pairs(a) do
					if a[i].mtype == 'video' or a[i].mtype == 'audio' or a[i].ftype == 'dir' or CheckExt(a[i].Adress) == false then v.Id = u ret[u] = v u = u + 1 end
					i = i + 1
				end
				if #ret == 0 then return end
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберите', 0, ret, 10000, 1)
			if id == nil then id = 1 end
			if ret[id].mtype == 'video' or ret[id].mtype == 'audio' then
				path = ret[id].Adress
				retAdr = getAdr(pubAdr, path)
			end
			title = ret[id].Name
				if ret[id].ftype == 'dir' then
					inAdr = pubAdr.. ret[id].Adress
					ge(inAdr)
				 return
				end
		end
	 return
	end
	ge(inAdr)
	m_simpleTV.Http.Close(session)
		if not retAdr then
			m_simpleTV.OSD.ShowMessage_UTF8('Медиа файлов не найдено', 102200, 5)
		 return
		end
	if not title then
		title = retAdr:match('filename=(.-)&') or 'Yandex видео'
		title = url_decode(title)
	end
	m_simpleTV.OSD.ShowMessageT({text = title, color = ARGB(255, 255, 255, 155), showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')