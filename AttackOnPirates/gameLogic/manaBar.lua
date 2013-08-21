module(..., package.seeall)

local barYposition = 125
local barXPosition = 10
local barWidth = 300
local manaViewXPosition
local manaViewYPosition

function new()
	local group = display.newGroup()
	local manaView = display.newGroup()

	group.currentMana = 100
 
	local greyBar = display.newRect(0, 0, barWidth, 11)
	greyBar:setReferencePoint(display.TopLeftReferencePoint)
	greyBar.x = barXPosition
	greyBar.y = barYposition
 	greyBar:setFillColor(125, 125, 125)
 	manaView:insert(greyBar)

	local blueBar = display.newRect(0, 0, barWidth, 11)
	blueBar:setReferencePoint(display.TopLeftReferencePoint)
	blueBar.x = barXPosition
	blueBar.y = barYposition
	blueBar:setFillColor(0, 0, 255, 220)
	manaView:insert(blueBar)
 
	local manaText = display.newText("0/0", 0, 0, "impact",13)
	manaText:setReferencePoint(display.BottomRightReferencePoint)
	manaText.x = 305
	manaText.y = 139
	manaView:insert(manaText)

	manaView:setReferencePoint(display.TopLeftReferencePoint)
	manaViewXPosition = manaView.x
	manaViewYPosition = manaView.y
	group:insert(manaView)

	function group:setMana(current, max)
		if current > max then current = max end
		local percent = current / max
		if percent == 0 then
			transition.to(blueBar, {time = 700, xScale = 0.0001, onComplete=function() blueBar.alpha = 0 end})
		else
			blueBar.alpha = 1
			transition.to(blueBar, {time = 700, xScale = percent})
		end
		self.currentMana = current
		local newManaText = current .. "/" .. max
		manaText.text = newManaText
		manaText:setReferencePoint(display.BottomRightReferencePoint)
		manaText.x = 305
		manaText.y = 139
	end

	function group:getMana()
		return self.currentMana
	end

	function group:addMpBy(n)
		if n > 0 then
			n = math.min(100, n*2)
			group:setMana(self.currentMana+n, 100)
			local addMpText = display.newText("+ " .. n, 0, 0, "impact", 13)
			addMpText:setReferencePoint(display.CenterReferencePoint)
			addMpText:setTextColor(153, 0, 255)
			addMpText.x = 160
			addMpText.y = 129
			addMpText.xScale = 2
			addMpText.yScale = 2
			addMpText.alpha = 0
			group:insert(addMpText)
			transition.to(addMpText, {time=500, alpha=1, xScale=1, yScale=1})
			transition.to(addMpText, {time=500, delay=500, y=addMpText.y - 40, onComplete=function(target) target:removeSelf() end})
		end
	end

 
	return group
end
