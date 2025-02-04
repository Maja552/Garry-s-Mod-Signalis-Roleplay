
local PANEL = {}

local radio_mockup = "eternalis/radio/radio_mockup.png"

local radio_icon_tuner = "eternalis/radio/radio_icon_tuner.png"
local radio_icon_welle = "eternalis/radio/radio_icon_welle.png"
local radio_icon_att = "eternalis/radio/radio_icon_att.png"
local radio_icon_burst = "eternalis/radio/radio_icon_burst.png"
local radio_icon_test = "eternalis/radio/radio_icon_test.png"
local radio_icon_signal = "eternalis/radio/radio_icon_signal.png"
local radio_icon_data = "eternalis/radio/radio_icon_data.png"

local sound_switch = "eternalis/signalis_ui/radio_switch.wav"
local sound_static = "sound/eternalis/signalis_radio/tcp_random_radio_static.mp3"

local static_enabled = false

local signals = {
	{
		frequency = 84000,
		snd = "sound/eternalis/signalis_radio/tcp_d1_12_three_note_odditiy_irdial.mp3",
		length = 245,
		is_burst = true,

		--snd = "sound/testTrack.wav",
		--length = 23,

		strength = 0.7,
		pos = Vector(203.994431, 4891.487793, -6245.80566),
		posMaxDistance = 10000
	},
	/*
	{
		frequency = 190000,
		snd = "sound/eternalis/signalis_radio/tcp_d1_01_the_swedish_rhapsody_irdial.mp3",
		length = 454,

		strength = 0.7,
		pos = Vector(1241.349365, 5154.740723, -6324.580566),
		posMaxDistance = 20000
	}
	*/
}

local size = 2
local bH = 48
local radioColor = Color(204, 53, 0, 255)

local enabled = false
local frequency = 160000
local freqIncreaseAmount = 50
local nextToggle = 0

local lastSignalDistance = nil

local loopedStaticSound = nil
local nextChangeVolume = 0
local nextStaticSoundPlay = 0

local function KillAllSounds()
    if static_enabled and IsValid(loopedStaticSound) then
        loopedStaticSound:SetVolume(0)
        loopedStaticSound:Stop()
        loopedStaticSound = nil
    end

	for k,v in pairs(signals) do
		if v.sound != nil and IsValid(v.sound) then
			v.sound:SetVolume(0)
			v.signalPaused = true
		end
	end
end

local function GetClosestSignal()
	local closestSignal = nil

	for k,v in pairs(signals) do
		if v.sound != nil and IsValid(v.sound) and v.lastDistance != nil and (closestSignal == nil or v.lastDistance < closestSignal.lastDistance) then
			closestSignal = v
		end
	end

	return closestSignal
end

local function frequencyChanged(panel, frequency)
	if IsValid(panel) and isnumber(panel.index) then
		local character = LocalPlayer():GetCharacter()
		if character then
			local inventory = character:GetInventory()
			if inventory then
				local items = inventory:GetItemsByUniqueID("module_radio", true)
				if items then
					for k,v in pairs(items) do
						if v.invID == panel.index then
							net.Start("ixRadioFrequency")
								net.WriteUInt(v.invID, 18)
								net.WriteUInt(frequency, 18)
							net.SendToServer()
							return
						end
					end
				end
			end
		end
	end
end

local function setEnabledAndFrequency(panel, enabled, frequency)
	if IsValid(panel) and isnumber(panel.index) then
		local character = LocalPlayer():GetCharacter()
		if character then
			local inventory = character:GetInventory()
			if inventory then
				local items = inventory:GetItemsByUniqueID("module_radio", true)
				if items then
					for k,v in pairs(items) do
						if v.invID == panel.index then
							net.Start("ixRadioEnabled")
								net.WriteUInt(v.invID, 18)
								net.WriteUInt(frequency, 18)
								net.WriteBool(enabled)
							net.SendToServer()
							return
						end
					end
				end
			end
		end
	end
end

local function FindClosestSignal()
	local closestSignal = nil
	local closestDistance = nil

	for k,v in pairs(signals) do
		local posDist = LocalPlayer():GetPos():Distance(v.pos)
		local posMaxDist = v.posMaxDistance * v.strength

		if posDist < posMaxDist and closestDistance == nil or posDist < closestDistance then
			closestSignal = v
			closestDistance = dist
		end
	end

	return closestSignal
end

local function WhileRadioRunning()
	if enabled then
		-- If we have a static sound and its not looping, and it has ended, then stop it
		if static_enabled and (IsValid(loopedStaticSound) and !loopedStaticSound:IsLooping() and nextStaticSoundPlay < CurTime()) then
			loopedStaticSound:Stop()
			loopedStaticSound = nil
		end

		-- If there is no static sound, play it
        if static_enabled and !IsValid(loopedStaticSound) then
			sound.PlayFile(sound_static, "noplay", function(station, errCode, errStr)
				if IsValid(station) then
					loopedStaticSound = station
					station:Play()
					nextStaticSoundPlay = CurTime() + 73
				end
			end)
        end

		for k,v in pairs(signals) do
			local freqDist = math.abs(frequency - v.frequency)

			local posDist = LocalPlayer():GetPos():Distance(v.pos)
			local posMaxDist = v.posMaxDistance * v.strength
			
			-- If we have a sound and its too far away, stop it
			if IsValid(v.sound) and (freqDist > 25000 or posDist > posMaxDist) then
				v.sound:SetVolume(0, 0)
				v.signalPaused = true
				v.lastDistance = nil
			end

			if freqDist < 40000 then
				v.lastDistance = freqDist

				if nextChangeVolume < CurTime() then
					nextChangeVolume = CurTime() + 0.02

					local intensity = math.Clamp(freqDist / 40000, 0.05, 1)

					-- Update volume of looped static
					if static_enabled and IsValid(loopedStaticSound) then
						loopedStaticSound:SetVolume(math.Clamp(intensity, 0.1, 1), 0)
					end

					if freqDist < 25000 then
						intensity = math.Clamp(freqDist / 25000, 0.05, 1)
 
						-- If we have a sound and its not looping, and it has ended, then play it
						if (IsValid(v.sound) and !v.sound:IsLooping() and v.nextSoundPlay < CurTime()) then
							v.sound:Stop()
							v.sound = nil
						end

						if !IsValid(v.sound) then
							-- If the sound is not playing, play it
							sound.PlayFile(v.snd, "noplay", function(station, errCode, errStr)
								if IsValid(station) then
									v.sound = station
									station:Play()
									v.nextSoundPlay = CurTime() + v.length
								end
							end)
						else
							-- If the sound is paused, play it
							if IsValid(v.sound) and v.sound:GetState() == GMOD_CHANNEL_PAUSED then
								v.sound:Play()
							end
						end

						-- If the sound is playing, set the volume
						if IsValid(v.sound) then
							v.sound:SetVolume(math.Clamp((1 - intensity) * v.strength, 0.1, 1), 0)
						end
					end
				end
			end
		end
	end
end

local last5FFTs = {}
local lastFFT = nil
local nextFFT = 0
local recombinedFFTs = nil

local function addAndCalculateLast5FFTs(fftData)
    -- Add the new FFT data to the end of the table
    table.insert(last5FFTs, fftData)
    
    if #last5FFTs > 5 then
        table.remove(last5FFTs, 1)
    end

	local combinedFFTs = {}
	for k,v in pairs(last5FFTs) do
		for i=1, 22 do
			if combinedFFTs[i] == nil then
				combinedFFTs[i] = 0
			end
			combinedFFTs[i] = combinedFFTs[i] + v[i]
		end
	end

	for i=1, 22 do
		if combinedFFTs[i] != nil then
			combinedFFTs[i] = combinedFFTs[i] / #last5FFTs
		end
	end

	return combinedFFTs
end

local function DrawOutsideRadio()
	if enabled then
	end
end

local is_icon_tuner_enabled = true
local is_icon_welle_enabled = true
local receivedSignal = 0
local transcription_text = ""

local frequencyTextEntry = nil

function PANEL:Init()
	self:SetSize(146 * size, 255 * size + bH)
	self:SetPos(4, 4)
	self:SetTitle("Radio module")
	self:ParentToHUD()
	self:SetDeleteOnClose(true)
	self:SetMouseInputEnabled(true)

	local panel = self:Add("DPanel")
	panel:Dock(FILL)

	local btnPanel = self:Add("DPanel")
	btnPanel:Dock(BOTTOM)
	btnPanel:SetHeight(bH)

	local buttonDecrease = btnPanel:Add("DButton")
	buttonDecrease:SetText("")
	buttonDecrease:SetHeight(bH)
	buttonDecrease:Dock(LEFT)
	buttonDecrease.Paint = function(this, w, h)
		if enabled then
			draw.TextShadow({
				text = "<",
				font = "SignalisRadioButtons",
				pos = {w / 2, h / 2},
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = color_white
			}, 1, 255)
		end
	end
	buttonDecrease.Think = function()
		if enabled and buttonDecrease:IsDown() then
			frequency = math.Clamp(frequency - freqIncreaseAmount, 50000, 250000)
			frequencyChanged(self, frequency)
			frequencyTextEntry:SetValue(tostring(frequency))
		end
	end

	local btn = btnPanel:Add("DButton")
	btn:SetMouseInputEnabled(true)
	btn:SetText("")
	btn:SetSize(146 * size - 12, bH)
	btn:Dock(FILL)
	btn.DoClick = function()
		if nextToggle < CurTime() then
			enabled = !enabled
			surface.PlaySound(sound_switch)
			nextToggle = CurTime() + 0.2

			setEnabledAndFrequency(self, enabled, frequency)

			if !enabled then
				KillAllSounds()
				hook.Remove("Tick", "SignalisRadioTick")
				hook.Remove("HUDPaint", "SignalisRadioDrawOutside")
				frequencyTextEntry:SetText("")
				frequencyTextEntry:SetDisabled(true)
			else
				hook.Add("Tick", "SignalisRadioTick", WhileRadioRunning)
				hook.Add("HUDPaint", "SignalisRadioDrawOutside", DrawOutsideRadio)
				frequencyTextEntry:SetDisabled(false)
				frequencyTextEntry:SetValue(tostring(frequency))
			end
		end
	end
	btn.Paint = function(this, w, h)
		surface.SetDrawColor(radioColor.r, radioColor.g, radioColor.b, 255)
		surface.DrawRect(4, 4, w - 8, h - 8)

		surface.SetDrawColor(25, 25, 25, 255)
		surface.DrawRect(6, 6, w - 12, h - 12)

		local text = "Turn on"
		if enabled then
			text = "Turn off"
		end
		draw.TextShadow({
			text = text,
			font = "SignalisRadioFontToggle",
			pos = {w / 2, h / 2},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = color_white
		}, 1, 255)
	end

	local buttonIncrease = btnPanel:Add("DButton")
	buttonIncrease:SetText("")
	buttonIncrease:SetHeight(bH)
	buttonIncrease:Dock(RIGHT)
	buttonIncrease.Paint = function(this, w, h)
		if enabled then
			draw.TextShadow({
				text = ">",
				font = "SignalisRadioButtons",
				pos = {w / 2, h / 2},
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = color_white
			}, 1, 255)
		end
	end
	buttonIncrease.Think = function()
		if enabled and buttonIncrease:IsDown() then
			frequency = math.Clamp(frequency + freqIncreaseAmount, 50000, 250000)
			frequencyTextEntry:SetValue(tostring(frequency))
			frequencyChanged(self, frequency)
		end
	end

	local img_bg = vgui.Create("DImage", panel)
	img_bg:Dock(FILL)
	img_bg:SetImage(radio_mockup)

	local bar_range_start = 47 * size
	local bar_range_width = 82 * size

	local bar_width = 2 * size
	local bar_height = 8 * size

	local signal_bars_start = 45 * size
	local signalis_bars = {
		-- 7 x 4
		[1] = 4,
		[2] = 4,
		[3] = 4,
		[4] = 4,
		[5] = 4,
		[6] = 4,
		[7] = 4,

		[8] = 3,

		-- 8 x 4
		[9] = 4,
		[10] = 4,
		[11] = 4,
		[12] = 4,
		[13] = 4,
		[14] = 4,
		[15] = 4,
		[16] = 4,

		[17] = 3,

		-- 8 x 4
		[18] = 4,
		[19] = 4,
		[20] = 4,
		[21] = 4,
		[22] = 4,
		[23] = 4,
		[24] = 4,
		[25] = 4,

		[26] = 3,

		-- 8 x 4
		[27] = 4,
		[28] = 4,
		[29] = 4,
		[30] = 4,
		[31] = 4,
		[32] = 4,
		[33] = 4,
		[34] = 4,

		[35] = 3,

		-- 9 x 4
		[36] = 4,
		[37] = 4,
		[38] = 4,
		[39] = 4,
		[40] = 4,
		[41] = 4,
		[42] = 4,
		[44] = 4,
		[45] = 4,
	}

	local signal_bar_height = 2

	if is_icon_tuner_enabled then
		local img_icon_tuner = vgui.Create("DImage", img_bg)
		img_icon_tuner:SetImage(radio_icon_tuner)
		img_icon_tuner:Dock(FILL)
		local originalPaint = img_icon_tuner.Paint
		img_icon_tuner.Paint = function(this, w, h)
			if enabled then
				originalPaint(this, w, h)
			end
		end
	end

	if is_icon_welle_enabled then
		local img_icon_welle = vgui.Create("DImage", img_bg)
		img_icon_welle:SetImage(radio_icon_welle)
		img_icon_welle:Dock(FILL)
		local originalPaint = img_icon_welle.Paint
		img_icon_welle.Paint = function(this, w, h)
			if enabled then
				originalPaint(this, w, h)
			end
		end
	end

	local img_icon_data = vgui.Create("DImage", img_bg)
	img_icon_data:SetImage(radio_icon_data)
	img_icon_data:Dock(FILL)
	local originalDataPaint = img_icon_data.Paint
	img_icon_data.Paint = function(this, w, h)
		if enabled then
			local signal = GetClosestSignal()
			if signal and signal.lastDistance and signal.lastDistance < 30000 then
				originalDataPaint(this, w, h)
			end
		end
	end

	local img_icon_signal = vgui.Create("DImage", img_bg)
	img_icon_signal:SetImage(radio_icon_signal)
	img_icon_signal:Dock(FILL)
	local originalSignalPaint = img_icon_signal.Paint
	img_icon_signal.Paint = function(this, w, h)
		if enabled then
			local signal = GetClosestSignal()
			if signal and signal.lastDistance and signal.lastDistance < 30000 and receivedSignal > CurTime() then
				originalSignalPaint(this, w, h)
			end
		end
	end

	local img_icon_burst = vgui.Create("DImage", img_bg)
	img_icon_burst:SetImage(radio_icon_burst)
	img_icon_burst:Dock(FILL)
	local originalBurstPaint = img_icon_burst.Paint
	img_icon_burst.Paint = function(this, w, h)
		if enabled then
			local signal = GetClosestSignal()
			if signal and signal.lastDistance and signal.lastDistance < 30000 and signal.is_burst then
				originalBurstPaint(this, w, h)
			end
		end
	end

	local transcription_panel = vgui.Create("DImage", img_bg)
	transcription_panel:Dock(FILL)
	transcription_panel.Paint = function(this, w, h)
		if enabled then
			draw.Text({
				text = transcription_text,
				font = "SignalisRadioTranscription",
				pos = {8, 8},
				xalign = TEXT_ALIGN_TOP,
				yalign = TEXT_ALIGN_LEFT,
				color = color_black
			}, 1, 255)
		end
	end

	local img_overlay = vgui.Create("DPanel", img_bg)
	img_overlay:Dock(FILL)
	img_overlay.Paint = function(this, w, h)
		draw.Text({
			text = "RECEIVER",
			font = "SignalisRadioReceiver",
			pos = {w / 2, 9 * size},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = color_black
		}, 1, 255)

		if enabled then
			-- draw frequency
			/*
			local frq = tostring(frequency)
			if string.len(frq) < 6 then
				frq = "0" .. frq
			end
			draw.Text({
				text = string.Left(frq, 3) .. "." .. string.Right(frq, 3),
				font = "SignalisRadioFrequency",
				pos = {w / 2 + 2, 39 * size},
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = radioColor
			}, 1, 255)
			*/

			-- frequency bar
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawRect(bar_range_start + (bar_range_width * ((frequency - 50000) / 200000)), 68 * size, bar_width, bar_height)

			-- signal bars
			local signal = GetClosestSignal()
			local pos = signal_bars_start
			local isOdd = true
			local num = 1

			if signal and signal.sound and (lastFFT == nil or nextFFT < CurTime()) then
				lastFFT = AnalyzeFFT(signal.sound)

				recombinedFFTs = addAndCalculateLast5FFTs(lastFFT)

				nextFFT = CurTime() + 0.005
			end

			for k,v in pairs(signalis_bars) do
				isOdd = !isOdd

				if isOdd then
					local barLength = signal_bar_height

					if signal != nil then
						local dist = 1 - (signal.lastDistance / 40000)
						local signalStrength = dist * signal.strength

						if recombinedFFTs then
							barLength = math.Clamp(((recombinedFFTs[num] * 1000) * signalStrength) * 2, signal_bar_height, 120)

							if barLength > 30 then
								receivedSignal = CurTime() + 0.07
							end
						end
						num = num + 1
					end

					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawRect(pos, (140 * size) - barLength, v, barLength)
				end
 
				pos = pos + v
			end
		end
	end

	frequencyTextEntry = vgui.Create("DTextEntry", self)
	frequencyTextEntry:SetPos(28 * size + 1 + 4, 34 * size + 1)
	frequencyTextEntry:SetSize(92 * size - 2 - 4, 36 * size)
	frequencyTextEntry:SetNumeric(true)
	frequencyTextEntry:SetEditable(true)
	frequencyTextEntry:SetDisabled(false)
	frequencyTextEntry:SetMultiline(false)

	local originalCaretPos = nil
	frequencyTextEntry.Think = function()
		if enabled and originalCaretPos == nil and frequencyTextEntry:GetCaretPos() != 0 then
			if originalCaretPos != frequencyTextEntry:GetCaretPos() then
				originalCaretPos = frequencyTextEntry:GetCaretPos()
				frequencyTextEntry.Think = nil
			end
		end
	end

	frequencyTextEntry.OnValueChange = function(this, value)
		if value then
			changedValue = true

			if tonumber(value) > 200000 then
				local caretPos = this:GetCaretPos()
				this:SetText("200000")
				this:SetCaretPos(caretPos - 1)
				frequency = 200000

			elseif tonumber(value) < 50000 then
				local caretPos = this:GetCaretPos()
				this:SetText("50000")
				this:SetCaretPos(caretPos + 1)
				frequency = 50000
			else

				frequency = tonumber(value)
			end
		end
	end
	frequencyTextEntry:SetFont("SignalisRadioFrequency")
	frequencyTextEntry:SetPaintBackground(false)
	frequencyTextEntry:SetTextColor(color_white)

	frequencyTextEntry.Paint = function(this, w, h)
		if enabled then
			local txt = this:GetText()
			local caretPos = this:GetCaretPos()

			surface.SetFont("SignalisRadioFrequency")
			local cW, cH = surface.GetTextSize("9")
			local sW, sH = surface.GetTextSize(txt)
			local tW, tH = surface.GetTextSize(string.sub(txt, 1, caretPos))

			-- draw caret pos line after the text
			draw.Text({
				text = txt,
				font = "SignalisRadioFrequency",
				pos = {w / 2, h / 2 + 2},
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = radioColor
			}, 1, 255)

			if originalCaretPos then
				-- draw caret
				draw.Text({
					text = "|",
					font = "SignalisRadioFrequency",
					pos = {((w - sW) / 2) + tW - (cW / 2), h / 2 + 2},
					xalign = TEXT_ALIGN_LEFT,
					yalign = TEXT_ALIGN_CENTER,
					color = color_white
				}, 1, 255)
			end
		end
	end

	if enabled then
		frequencyTextEntry:SetValue(tostring(frequency))
	end
end

vgui.Register("ixRadioPanel", PANEL, "DFrame")
