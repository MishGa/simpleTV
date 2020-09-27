-- видеоскрипт для сайта https://www.dropbox.com (22/9/19)
-- открывает подобные ссылки:
-- https://www.dropbox.com/s/dvspvf22x2y7vby
-- https://www.dropbox.com/sh/kidub9saizdl7ra/AAAs3OcUga7iW_HeHX6pJ29oa/2.wmv?dl=0
-- https://www.dropbox.com/s/ym4br2u3ownm30t/evidence.mp4
-- https://www.dropbox.com/s/kimukvqsbum379g/1x03.HIMYM%20-%20JingKing.mkv?dl=0
-- https://www.dropbox.com/s/ypvn9sjsteeg6tf/EN%20HAUT%20EN%20BAS%20A%20GAUCHE%20A%20DROITE.mp3?dl=1
-- https://www.dropbox.com/s/dvspvf22x2y7vby/Shawn%20Mendes%2C%20Camila%20Cabello%20-%20Se%C3%B1orita%20%28Lyrics%29.mp3?raw=1~Senorita
-- https://www.dropbox.com/s/eyb1jqi06zmiwap/11_MHW-IB_PV3_PS4_FR
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
		if not inAdr then return end
		if not inAdr:match('^https?://www%.dropbox%.com/sh?/') then return end
	m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = 'https://heavyeditorial.files.wordpress.com/2014/04/logotype-vflfbf9py.png?w=780', TypeBackColor = 0, UseLogo = 1, Once = 1})
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local retAdr = inAdr:gsub('%?.-$', '')
	retAdr = retAdr .. '?dl=1'
	m_simpleTV.Control.CurrentAdress = retAdr
	local title = retAdr:match('/s/.-/(.+)%?') or 'Dropbox'
	title = title:gsub('%....$', '')
	title = m_simpleTV.Common.fromPersentEncoding(title)
	if m_simpleTV.Control.CurrentTitle_UTF8 then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
-- debug_in_file(retAdr .. '\n')