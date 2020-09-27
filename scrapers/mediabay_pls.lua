-- скрапер TVS для загрузки плейлиста "mediabay" с сайта http://mediabay.tv (7/1/19)
-- переименовать каналы ------------------------------------------------
local filter = {
	{'8 Канал Красноярский край- RU', '8 канал (Красноярск)'},
	{'РТР - ПЛАНЕТА - RU - TEST', 'РТР-Планета (Азия)'},
	{'Первый - RU - TEST', 'Первый канал (Азия)'},
	{'Russia Today Documentary - RU', 'RTД'},
	{'Russia Today - RU', 'Russia Today'},
	{'CBC (Caspian Broadcasting Company) - AZ', 'CBC'},
	{'Россия 24 - RU - TEST', 'Россия 24'},
	{'8 ТВ Москва - RU', '8 канал'},
	{'Афонтово', 'Афонтово (Красноярск)'},
	{'Дагестан', 'Дагестан (Махачкала)'},
	{'Звезда - RU', 'Звезда'},
	{'Ингушетия', 'Ингушетия (Магас)'},
	{'Краснодар', 'Краснодар он-лайн (Краснодар)'},
	{'Мир 24 - RU', 'Мир 24'},
	}
--------------------------------------------------------------------------
	module('mediabay_pls', package.seeall)
	local my_src_name = 'mediabay'
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
		local scrap_settings
		scrap_settings = {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\mediabay.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 0, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0}}
	 return scrap_settings
	end
	function GetVersion() return 2, 'UTF-8' end
	function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.2785.143 Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL2FwaW02Lm1lZGlhYmF5LnR2L3YyL2NoYW5uZWxzL2NoYW5uZWxz')})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		require 'json'
		local tab = json.decode(answer:gsub('(%[%])', '"nil"'))
			if not tab then return end
		local t, i = {}, 1
			while true do
					if not tab.data[i] then break end
				t[i] = {}
				t[i].Id = i
				t[i].name = tab.data[i].name
				t[i].address = 'http://mediabay.tv/tv/' .. tab.data[i].id
				i = i + 1
			end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls then return end
		t_pls = ProcessFilterTableLocal(t_pls)
		m_simpleTV.OSD.ShowMessage_UTF8(Source.name .. ' -> ' .. #t_pls, 0xffaf00, 5)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return nil end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')