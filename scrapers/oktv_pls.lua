-- скрапер TVS для загрузки плейлиста "OK-TV" с сайта http://ok-tv.org (29/6/20)
-- необходим видоскрипт: oktv
-- ## прокси ##
local proxy = ''
-- '' - нет
--  'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ##
-- переименовать каналы ------------------------------------------------------------------
local filter = {
	{'1000', 'TV1000'},
	{'1000 Action', 'TV1000 Action'},
	{'1000 Comedy', 'ViP Comedy'},
	{'1000 Megahit', 'ViP Megahit'},
	{'1000 Premium', 'ViP Premiere'},
	{'1000 Русское кино', 'TV1000 Русское кино'},
	{'Крым 1', 'Первый Крымский (Симферополь)'},
	{'Че ТВ', 'Че'},
	{'Ералаш', 'ЕРАЛАШ HD'},
	{'Наука 2', 'Наука'},
	{'5 Канал', '5 Канал Украина'},
	{'Дважды два канал (2x2)', '2x2'},
	{'Сетанта Спорт Плюс', 'Setanta Sports+'},
	{'ТРО союз', 'БелРос'},
	{'Fox live', 'Fox Life'},
	{'Кино HD', 'Кинопремьера'},
	{'Комедия', 'Кинокомедия'},
	{'Супер канал', 'Супер'},
	{'Морской канал', 'Морской'},
	{'КиноПремиум HD', 'Кино Премиум HD'},
	{'Канал О!', 'О!'},
	{'Кухня', 'Кухня ТВ'},
	{'Канал История', 'История'},
	{'Канал A1', 'A1'},
	{'Канал A2', 'A2'},
	{'Драйв тв', 'Драйв'},
	{'Бобер ТВ', 'Бобер'},
	{'SET (Sony TV)', 'Sony Channel'},
	{'Сетанта-Спорт (Setanta Sports)', 'Setanta Sports'},
	{'Сетанта-Спорт плюс (Setanta Sports+)', 'Setanta Sports+'},
	{'ТНТ-Music', 'ТНТ Music'},
	}
------------------------------------------------------------------------------------------
	module('oktv_pls', package.seeall)
	local my_src_name = 'OK-TV'
	local function ProcessFilterTableLocal(t)
		if not type(t) == 'table' then return end
		for i = 1, #t do
			t[i].name = tvs_core.tvs_clear_double_space(t[i].name)
			for _, ff in ipairs(filter) do
				if (type(ff) == 'table' and t[i].name == ff[1]) then
					t[i].name = ff[2]
				end
			end
		end
	 return t
	end
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\oktv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 0, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.2785.143 Safari/537.36', proxy, false)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = 'http://ok-tv.org'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local i, t = 1, {}
		local adr, title
			for w in answer:gmatch('<a href="/channels/.-</a>') do
				adr = w:match('href="([^"]+)')
				title = w:match('title="([^"]+)')
					if not adr or not title then break end
				t[i] = {}
				t[i].name = title:gsub(' смотреть онлайн.-$', '')
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
			if not t_pls then
				m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' - ошибка загрузки плейлиста', color = 0xffff6600, showTime = 1000 * 5, id = 'channelName'})
			 return
			end
		t_pls = ProcessFilterTableLocal(t_pls)
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' (' .. #t_pls .. ')', color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')