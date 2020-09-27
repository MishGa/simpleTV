-- скрапер TVS для загрузки плейлиста "telecola" https://telecola.tv (17/4/20)
-- необходим видоскрипт: telecola
-- логин, пароль установить в 'Password Manager', для id - telecola
-- ## Переименовать каналы ##
local filter = {
	{'', ''},
	}
-- ##
	module('telecola_pls', package.seeall)
	local my_src_name = 'telecola'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\telecola.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local url
		local error_text, pm = pcall(require, 'pm')
		local ret, login, pass
		if package.loaded.pm then
			ret, login, pass = pm.GetTestPassword('telecola', 'telecola', true)
			if login and pass and login ~= '' and pass ~= '' then
				login = m_simpleTV.Common.toPercentEncoding(login)
				pass = m_simpleTV.Common.toPercentEncoding(pass)
				url = 'https://api.telecola.tv/api/json/login?login=' .. login .. '&pass=' .. pass
			end
		end
			if not url then
			 return 0
			end
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/79.0.3785.143 Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		local sid = answer:match('"sid":%s*"([^"]+)')
		local sid_name = answer:match('"sid_name":%s*"([^"]+)')
			if not sid or not sid_name then return end
		sid = sid_name .. '=' .. sid
		url = 'https://api.telecola.tv/api/json/channel_list?' .. sid
		rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub(':%s*%[%]', ':""')
		answer = answer:gsub('%[%]', ' ')
		require 'json'
		tab = json.decode(answer)
			if not tab or not tab.groups then return end
		local t, i = {}, 1
		local j = 1
			while true do
						if not tab.groups[j]
							or not tab.groups[j].channels
						then
						 break
						end
				local k = 1
				-- local uniq = {}
					while tab.groups[j].channels[k] do
						t[i] = {}
						t[i].name = unescape3(tab.groups[j].channels[k].name)
						-- t[i].group = unescape3(tab.groups[j].name)
						-- t[i].logo = tab.groups[j].channels[k].icon
						t[i].address = 'https://player.telecola.tv/' .. tab.groups[j].channels[k].id
						-- if not uniq[t[i].address] then
							-- t[i].address = t[i].address .. '?group=' .. (t[i].group or '')
							-- uniq[t[i].address] = t[i].address
						-- end
						if tab.groups[j].channels[k].have_archive
							and tab.groups[j].channels[k].have_archive == 1
						then
							t[i].RawM3UString = 'catchup="append" catchup-days="10"'
												.. ' catchup-source=""'
						end
						i = i + 1
						k = k + 1
					end
				j = j + 1
			end
			if i == 1 then return end
		if not m_simpleTV.User then
			m_simpleTV.User = {}
		end
		if not m_simpleTV.User.telecola then
			m_simpleTV.User.telecola = {}
		end
		m_simpleTV.User.telecola.sid = sid .. '&protect_code=' .. pass
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls then
				m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' - ошибка загрузки плейлиста'
											, color = 0xffff6600
											, showTime = 1000 * 5
											, id = 'channelName'})
			 return
			end
			if t_pls == 0 then
				m_simpleTV.OSD.ShowMessageT({text = 'логин/пароль установить\nв дополнении "Password Manager"\nдля id - telecola'
											, color = 0xffff6600
											, showTime = 1000 * 5
											, id = 'channelName'})
			 return
			end
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
-- debug_in_file(#t_pls .. '\n')