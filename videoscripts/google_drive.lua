-- видеоскрипт для сайта https://drive.google.com (22/12/19)
-- открывает подобные ссылки:
-- https://drive.google.com/open?id=1i_EDJEQE24J_DwhkgY_tX_G1-9fiU5k8/
-- https://drive.google.com/file/d/15PQxmAa_KBI4EiW7qXnlPdKT-ciW2ZtZ/view?usp=drive_open
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAdress:match('^https?://drive%.google%.com') then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
	local logo = 'https://tagline.ru/file/service/logo/task-tracking-nonspec/google-drive-logo_tagline.png'
	m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = ''
	local retAdr = inAdr:match('/d/([^/]+)/?') or inAdr:match('id=([^/]+)/?')
		if not retAdr then return end
	retAdr = 'https://drive.google.com/uc?export=download&id=' .. retAdr .. '$OPT:NO-STIMESHIFT'
	if m_simpleTV.Common.GetVlcVersion() > 3000 then
		retAdr = retAdr .. '$OPT:no-gnutls-system-trust'
	end
	m_simpleTV.Control.CurrentAdress = retAdr
	m_simpleTV.Control.CurrentTitle_UTF8 = 'Google Drive'
	m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
-- debug_in_file(retAdr .. '\n')