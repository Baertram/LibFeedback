
-- Example:  LibFeedback:initializeFeedbackWindow(DolgubonSetCrafter, "Dolgubon's Lazy Set Crafter", "@Dolgubon", {TOPLEFT , owningWindow , TOPLEFT , 10, 10}, {0,5000,50000, "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7CZ3LW6E66NAU"})


local libLoaded
local LIB_NAME, VERSION = "LibFeedback", 0.1
local LibFeedback, oldminor = LibStub:NewLibrary(LIB_NAME, VERSION)
if not LibFeedback then return end
--_G["LibFeedback"] = LibFeedback

local buttonInfo = {0,5000,50000, "https://www.genericexampleurl.com/somemoregenericiness"}

local function SendNote(self)
	local p = self.parent
	if type(self.amount)=="string" then
		RequestOpenUnsafeURL(self.amount)
	else
		p.parentControl:SetHidden(true)
		SCENE_MANAGER:Show('mailSend')
		zo_callLater(function()
		ZO_MailSendToField:SetText(p.mailDestination)
		ZO_MailSendSubjectField:SetText(p.parentAddonName)
		QueueMoneyAttachment(self.amount)
		ZO_MailSendBodyField:TakeFocus() end, 200)
	end
end

local function createFeedbackButton(name, owningWindow)
	local button = WINDOW_MANAGER:CreateControlFromVirtual(name, owningWindow, "ZO_DefaultButton")
	local b = button
	b:SetDimensions(150, 28)
	b:SetHandler("OnClicked",function()SendNote(b) end)
	b:SetAnchor(BOTTOMLEFT,owningWindow, BOTTOMLEFT,5,5)
	return button
end

local function createShowFeedbackWindow(owningWindow)
	local showButton = WINDOW_MANAGER:CreateControl(owningWindow:GetName().."ShowFeedbackWindowButton", owningWindow, CT_BUTTON)
	local b = showButton
	b:SetDimensions(34, 34)
	b:SetNormalTexture("ESOUI/art/chatwindow/chat_mail_up.dds")
	b:SetMouseOverTexture("ESOUI/art/chatwindow/chat_mail_over.dds")
	b:SetHandler("OnClicked", function(self) self.feedbackWindow:ToggleHidden() end )
	return showButton
end

local function createFeedbackWindow(owningWindow)
	local feedbackWindow = WINDOW_MANAGER:CreateControl(owningWindow:GetName().."FeedbackWindow", owningWindow, CT_CONTROL)
	local c = feedbackWindow
	c:SetDimensions(545, 150)
	c:SetMouseEnabled(true)
	c:SetClampedToScreen(true)
	c:SetMovable(true)

	WINDOW_MANAGER:CreateControlFromVirtual(c:GetName().."BG", c, "ZO_DefaultBackdrop"):SetAnchorFill(c)
	local l = WINDOW_MANAGER:CreateControl(c:GetName().."Label", c, CT_LABEL)
	l:SetFont("ZoFontGame")
	l:SetAnchor(TOP, c,TOP0, 0, 5)
	l:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	l:SetColor(0.83, 0.76, 0.16)
	local b = WINDOW_MANAGER:CreateControl(c:GetName().."Close", c, CT_BUTTON)
	b:SetAnchor(CENTER, c,TOPRIGHT, -20, 20)
	b:SetDimensions(48, 48)
	b:SetNormalTexture("/esoui/art/hud/radialicon_cancel_up.dds")
	b:SetMouseOverTexture("/esoui/art/hud/radialicon_cancel_over.dds")
	b:SetHandler("OnClicked", function(self) self:GetParent():SetHidden(true) end )
	local n = WINDOW_MANAGER:CreateControl(c:GetName().."Note", c, CT_LABEL)
	n:SetText("If you found a bug, have a request or a suggestion, or simply wish to donate, send a mail.")
	n:SetDimensions(525, 200)
	n:SetAnchor(TOPLEFT, c, TOPLEFT, 10, 50)
	n:SetColor(1, 1, 1)
	n:SetFont("ZoFontGame")
	n:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	return feedbackWindow
end

--[[ /script LibFeedback:initializeFeedbackWindow(DolgubonSetCrafter, "Dolgubon's Lazy Set Crafter", "@Dolgubon", 
 {TOPLEFT , owningWindow , TOPLEFT , 10, 10}, 
 {0,5000,50000, "https://www.genericexampleurl.com/somemoregenericiness"}) --]]


function LibFeedback:initializeFeedbackWindow(parentAddonNameSpace, parentAddonName, parentControl, mailDestination,  mailButtonPosition, buttonInfo)
	local feedbackWindow = createFeedbackWindow(parentControl)

	parentAddonNameSpace.feedbackWindow = feedbackWindow
	feedbackWindow.parentControl = parentControl
	feedbackWindow.mailDestination = mailDestination
	feedbackWindow.parentAddonName = parentAddonName

	feedbackWindow:SetAnchor(TOPRIGHT,owningWindow, TOPLEFT, -40,0)
	feedbackWindow:SetHidden(true)

	feedbackWindow:SetDimensions(#buttonInfo*150 , 150)
	feedbackWindow:GetNamedChild("Label"):SetText(parentAddonName)

	local buttons = {}
	for i = 1, #buttonInfo do

		buttons[#buttons+1] =  createFeedbackButton(feedbackWindow:GetName().."Button"..#buttons, feedbackWindow)
		buttons[i]:SetAnchor(BOTTOM,feedbackWindow, BOTTOMLEFT, (i-1)*150+70,-10)
		buttons[i].amount = buttonInfo[i]
		buttons[i].SendNote = SendNote
		buttons[i].parent = feedbackWindow

		if buttonInfo[i] == 0 then
			buttons[i]:SetText("Send Note")
		elseif type(buttonInfo[i] )=="string" then
			buttons[i]:SetText("Send $$")
		else
			buttons[i]:SetText("Send "..tostring(buttonInfo[i]).." gold")
		end
	end
	local showButton = createShowFeedbackWindow(parentControl)

	showButton.feedbackWindow = feedbackWindow
	showButton:SetAnchor(unpack(mailButtonPosition))
	showButton:SetDimensions(40,40)

	return showButton, feedbackWindow
end
