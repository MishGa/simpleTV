-- видеоскрипт для сайта http://www.ontvtime.ru (28/8/19)
-- открывает подобные ссылки:
-- http://www.ontvtime.ru/general/ntv-6.html
-- http://www.ontvtime.ru/index.php?option=com_content&task=view_record&id=1421&start_record=2019-08-28-12-15
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('^https?://www%.ontvtime%.ru') then return end
	m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 3, Once = 1})
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/75.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	local cooki = m_simpleTV.Http.GetCookies(session, inAdr, '')
	m_simpleTV.Http.Close(session)
		if rc ~= 200 or not cooki then return end
	local host = cooki:match('tv=(.-);')
		if host:match('^%d+$') then
			local retAdr = answer:match('host == "' .. host .. '".-src="(.-)"')
				if not retAdr then return end
			m_simpleTV.Control.ChangeAdress = 'No'
			m_simpleTV.Control.CurrentAdress = retAdr:gsub('^//', 'http://'):gsub('&amp;', '&')
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
	local gid = answer:match('var gid = \'(.-)\'')
	local sid = cooki:match('tv2=(.-);')
		if not host or not gid or not sid then return end
	local time1 = cooki:match('tv1=(.-);') or ''
	local qlty
	if time1 ~= '' then
		qlty = 'a'
	else
		qlty = 'f'
	end
	local stream = qlty .. sid .. 'playlist.m3u8?time=' .. time1
	local retAdr = 'http://' .. m_simpleTV.Common.fromPersentEncoding(host) .. '/stream/' .. gid .. '/' .. stream
	local title = answer:match('id="ch_title">(.-)<') .. ' ' .. (answer:match('<span id="rec_date">(.-)<') or '')
	title = m_simpleTV.Common.multiByteToUTF8(title)
	if m_simpleTV.Control.CurrentTitle_UTF8 then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	if m_simpleTV.Common.GetVlcVersion() > 3000 then
		retAdr  = retAdr .. '$OPT:adaptive-use-access'
    end
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')