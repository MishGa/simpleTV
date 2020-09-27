-- скрапер TVS для загрузки плейлиста "PeersTV+" http://peers.tv (17/9/20)
-- Copyright © 2017-2020 Nexterr
-- ## необходим ##
-- видоскрипт: peersTV.lua
-- расширение дополнения httptimeshift: peerstv-timeshift_ext.lua
-- ## переименовать каналы ##
local filter = {
	{'Муз ТВ', 'МУЗ-ТВ'},
	{'Фест-ТВ', '1HD'},
	{'8 канал Красноярский край', '8 канал (Красноярск)'},
	{'Петербург-5 канал', 'Пятый канал'},
	{'Travel Adventure', 'Travel+ Adventure'},
	{'Тайны Галактики', 'Galaxy'},
	{'ТИВИКОМ', 'Тивиком (Улан-Удэ)'},
	{'ОРТРК-12 КАНАЛ', '12 канал (Омск)'},
	{'Барс плюс', 'Барс плюс (Иваново)'},
	{'360', '360 Подмосковье (Москва)'},
	{'ТВ Центр Красноярск', 'Центр Красноярск (Красноярск)'},
	{'ШАДР-инфо', 'Шадр-Инфо (Шадринск)'},
	{'2x2', '2x2 (+4)'},
	{'СТС', 'СТС Мир'},
	{'Кино 24', 'KINO 24'},
	{'Алмазный край', 'Алмазный край (Якутск)'},
	{'Катунь 24', 'Катунь 24 (Барнаул)'},
	{'FastNFunBOX', 'Fast&FunBox'},
	{'Erox (18+)', 'Erox HD'},
	{'Brazzers TV Europe (18+)', 'Brazzers TV Europe'},
	{'blue HUSTLER (18+)', 'Blue Hustler'},
	{'86', '86 Канал (Сургут)'},
	{'Вся Уфа', 'Вся Уфа (Уфа)'},
	{'Липецкое время', 'Липецкое время (Липецк)'},
	{'НАШ ДОМ', '11 канал (Пенза)'},
	{'Якутия 24', 'Якутия 24 (Якутск)'},
	{'ЮТВ', 'Ю'},
	{'Юрган', 'Юрган (Сыктывкар)'},
	{'ТиВиСи', 'ТиВиСи HD (Иркутск)'},
	{'ОТС [HD]', 'ОТС (Новосибирск)'},
	{'НТН24', 'НТН24 (Новосибирск)'},
	{'Альтес', 'Альтес (Чита)'},
	{'Арктика 24', 'Арктика 24 (Ноябрьск)'},
	{'НВК САХА', 'Саха (Якутск)'},
	{'НТВ-Право', 'НТВ Право'},
	{'НТВ-Сериал', 'НТВ Сериал'},
	{'НТВ-Стиль', 'НТВ Стиль'},
	{'НТВ-Хит', 'НТВ Хит'},
	{'a2', 'A2'},
	{'ЗабТВ', 'Заб.TV (Чита)'},
	{'Нижний Новгород 24', 'Нижний Новгород 24 (Нижний Новгород)'},
	{'Салям', 'Салям (Уфа)'},
	{'ТК Центр Красноярск HD', 'Центр Красноярск (Красноярск)'},
	{'Эфир-Казань', 'Эфир (Казань)'},
	{'Russian Travel Guide', 'RTG'},
	}
-- ##
	module('peersTV_plus_pls', package.seeall)
	local my_src_name = 'PeersTV+'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\peers.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local outm3u, err = tvs_func.get_m3u(decode64('aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL05leHRlcnIvc2ltcGxlVFYucGxheWxpc3RzL21hc3Rlci9wZWVycy50eHQ'))
		if err ~= '' then tvs_core.tvs_ShowError(err) m_simpleTV.Common.Sleep(1000) end
			if not outm3u or outm3u == '' then return '' end
		outm3u = outm3u:gsub('#EXTM3U.-\n', '#EXTM3U\n')
		outm3u = outm3u:gsub('#EXTINF[^,]+,', '#EXTINF:-1 catchup="append" catchup-minutes="180" catchup-source="&offset=${offset}",')
-- debug_in_file(outm3u .. '\n')
		local t_pls = tvs_core.GetPlsAsTable(outm3u)
		t_pls = ProcessFilterTableLocal(t_pls)
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' (' .. #t_pls .. ')'
									, color = 0xff99ff99
									, showTime = 1000 * 5
									, id = 'channelName'})
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end