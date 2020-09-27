-- скрапер TVS для сайта https://www.lostfilm.tv [новые серии] (26/6/20)
-- ## зеркало ##
local url = ''
-- '' = нет
-- 'https://www.lostfilm.run' (пример)
-- ## прокси ##
local prx = ''
-- '' - нет
--  'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ##
	module('lostfilm_new_pls', package.seeall)
	local my_src_name = 'Lostfilm (новые серии)'
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\lostfilm.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 0, AutoBuild = 1, AutoBuildDay = {1, 1, 1, 1, 1, 1, 1}, LastStart = 0, TVS = {add = 0, FilterCH = 0, FilterGR = 0, GetGroup = 0, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 2}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.2785.143 Safari/537.36', prx, false)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		if url == '' then
			url = 'https://www.lostfilm.tv'
		end
		local rc, answer = m_simpleTV.Http.Request(session, {url = url .. '/new/'})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local t, i = {}, 1
		local name, ser_name, ser, adr, logo
			for w in answer:gmatch('<div class="row">(.-)Дата выхода Eng') do
				name = w:match('<div class="name%-ru">(.-)</div>')
				ser_name = w:match('<div class="alpha">(.-)</div>')
				ser = w:match('<div class="left%-part">(.-)</div>')
				adr = w:match('href="(.-)"')
				da = w:match('Дата выхода Ru: (.-)%.20') or ''
				da = da:gsub('%.', '/')
				logo = w:match('<img src="(.-)"') or ''
					if not name or not adr or not ser_name or not ser then break end
				t[i] = {}
				t[i].group = my_src_name
				t[i].logo = logo:gsub('^//', 'https://')
				name = da .. ' ' .. name .. ' - ' .. ser .. ' "' .. ser_name ..'"'
				t[i].name = name:gsub(',', ' '):gsub('%s%s+', ' ')
				t[i].address = url .. adr
				i = i + 1
			end
				if i == 1 then return end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls then m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' - ошибка загрузки плейлиста', color = 0xffff6600, showTime = 1000 * 5, id = 'channelName'}) return end
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' - найдено ' .. #t_pls .. ' серий', color = 0xff9bffff, showTime = 1000 * 5, id = 'channelName'})
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')