-- (12/5/20)
	require 'ex'
	require 'json'
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	if not package.path:match('user/video/core', 0) then
		package.path = package.path .. ';' .. m_simpleTV.MainScriptDir .. 'user/video/core/?.lua'
	end
	m_simpleTV.Logger.WriteToLog(m_simpleTV.Common.fromPercentEncoding(m_simpleTV.Common.multiByteToUTF8(m_simpleTV.Control.CurrentAddress)), 0, 'Address')
	local pathname = m_simpleTV.MainScriptDir .. 'user/video/'
	if m_simpleTV.Common.isX64() then
		for entry in os.dir(pathname) do
			if entry.name:match('%.lua$')
				and not entry.name:match('x32%.lua$')
				and not entry.name:match('^video%.lua$')
			then
				dofile (m_simpleTV.MainScriptDir .. 'user/video/' .. entry.name)
					if m_simpleTV.Control.ChangeAddress ~= 'No' then break end
			end
		end
	else
		for entry in os.dir(pathname) do
			if entry.name:match('%.lua$')
				and not entry.name:match('x64%.lua$')
				and not entry.name:match('^video%.lua$')
			then
				dofile (m_simpleTV.MainScriptDir .. 'user/video/' .. entry.name)
					if m_simpleTV.Control.ChangeAddress ~= 'No' then break end
			end
		end
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')