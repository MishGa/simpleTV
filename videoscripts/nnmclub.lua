-- видеоскрипт для сайта http://nnm-club.me (9/8/18)
-- необходим Acestream
-- открывает подобные ссылки:
-- http://nnmclub.tv/forum/viewtopic.php?t=1204682
-- http://nnm-club.me/forum/download.php?id=981168
-- http://[2001:470:1f15:f1::1113]/forum/viewtopic.php?t=1203587
-- http://nnmclub.to/forum/viewtopic.php?t=1203119
-- http://[2a01:d0:e451:0:6e6e:6d2d:636c:7562]/forum/download.php?id=798242
-- https://ipv6.nnm-club.me/forum/viewtopic.php?t=1202255
-- https://ipv6.nnmclub.to/forum/viewtopic.php?t=1203629
---------------------------------------------------------------------------------
local subt = 0 -- субтитры: 0 - по умолч., 1 - откл. при запуске
---------------------------------------------------------------------------------
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('https?://nnm%-club%.me') and not inAdr:match('https?://nnmclub%.tv') and not inAdr:match('https?://nnmclub%.to/') and not inAdr:match('https?://%[2001:470:1f15:f1::1113%]') and not inAdr:match('https?://%[2a01:d0:e451:0:6e6e:6d2d:636c:7562%]') and not inAdr:match('https?://ipv6%.nnm%-club%.me') and not inAdr:match('https?://ipv6%.nnmclub%.to') then return end
		if not inAdr:match('%.php%?') then return end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/68.0.2785.143 Safari/537.36', nil, true)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	m_simpleTV.Http.SetRedirectAllow(session, false)
	local title
	if inAdr:match('viewtopic%.php') then
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				m_simpleTV.OSD.ShowMessage_UTF8('nnnmclub ошибка[1]-' .. rc, 255, 5)
			 return
			end
		local id = answer:match('attach_id=(%d+)')
			if not id then
				m_simpleTV.Http.Close(session)
				m_simpleTV.OSD.ShowMessage_UTF8('nnnmclub ошибка[2]', 255, 5)
			 return
			end
		title = answer:match('<title>(.-)</title>') or 'nnm-club'
		title = m_simpleTV.Common.multiByteToUTF8(title)
		title = title:gsub(':: NNM%-Club', '')
		inAdr = inAdr:match('https?://.-/') .. '/forum/download.php?id=' .. id
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 302 then m_simpleTV.Http.Close(session) return end
	local header = m_simpleTV.Http.GetRawHeader(session)
		if not header then m_simpleTV.Http.Close(session) return end
	inAdr = header:match('Location: (.-)\n')
		if not inAdr then m_simpleTV.Http.Close(session) return end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr:gsub('^//', 'http://'), writeinfile = true})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.OSD.ShowMessage_UTF8('nnnmclub ошибка[3]-' .. rc, 255, 5)
		 return
		end
	m_simpleTV.Control.CurrentTitle_UTF8 = title or 'nnm-club'
	local retAdr = 'torrent://' .. answer
	if subt > 0 then retAdr = retAdr .. '$OPT:no-spu' end
	m_simpleTV.Control.CurrentAdress = retAdr
-- debug_in_file(retAdr .. '\n')