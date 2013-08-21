--[[

The main menu of the game

--]]

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local energy = require 'gameLogic.energy'
local gameCoins = require 'gameLogic.gameCoins'
local gameDiamonds = require 'gameLogic.gameDiamonds'
local gameKeys = require 'gameLogic.gameKeys'
local experience = require 'gameLogic.experience'
local facebookHelper = require 'gameLogic.facebookHelper'
local localStorage = require 'gameLogic.localStorage'
local mainSoundEffect = require 'gameLogic.mainSoundEffect'
local toast = require 'gameLogic.toast'
local widget = require 'widget'
local luckyDraw = require 'gameLogic.luckyDraw'
local levelSetting = require 'gameLogic.levelSetting'
local statTable = levelSetting.getTable("mainCharStat")

------------------------------ FORWARD REF -----------------------------
local energyTable
local buttonIsPressed
local unfreezeButtonTimer
local buttonPressTimeDelay = 500
local menuXPosn = 400
local chestXPosn = -400
local menuLayout
local chestLayout
local gameKeysText
local energyBottleText
local itemStat
local soundEffect
---------------------------------------------------------------------------------


---------------------------HELPER FUNCTIONS ------------------------------
local function unfreezeButton()
    buttonIsPressed = false
end


-- Draw game menu UI
---------------------------------------------------------------------------
local function drawUpperLayout()
    local group = display.newGroup()
    
    local energy = energyTable["screen"]
    group:insert(energy)

    local function onComplete(event)
        if "clicked" == event.action then
            local i = event.index
            if 1 == i then
                -- do nothing (cancel)
            elseif 2 == i then
                local currentEnergyBottle = localStorage.get("energyBottle") - 1
                localStorage.saveWithKey("energyBottle", currentEnergyBottle)
                energyBottleText.text = currentEnergyBottle
                energyTable["screen"]:restoreEnergy()
                toast.new("Entirely recovered energy.", 3000)
            end
        end
    end
    local function energyButtonListener(event)
        local currentEnergyBottle = localStorage.get("energyBottle")
        if event.phase == "began" and currentEnergyBottle > 0 then
            soundEffect:play("button")
            local alert = native.showAlert( "Energy Potion", "Are you sure?", { "No", "Yes" }, onComplete )
        end
    end
    local energyButton = widget.newButton{
        defaultFile = "images/buttons/buttonUseenergy.png",
        onEvent = energyButtonListener
    }
    energyButton.x = 190
    energyButton.y = 38
    group:insert(energyButton)

    local gameCoins = gameCoins.new()
    gameCoins.y = gameCoins.y - 4
    itemStat["coins"] = gameCoins
    group:insert(gameCoins)

    local gameDiamonds = gameDiamonds.new()
    gameDiamonds.y = gameDiamonds.y - 4
    itemStat["diamonds"] = gameDiamonds
    group:insert(gameDiamonds)

    local function IAPButtonListener( event )
        if event.phase == "began" and not buttonIsPressed then
            soundEffect:play("button")
            buttonIsPressed = true
            unfreezeButtonTimer = timer.performWithDelay(buttonPressTimeDelay, unfreezeButton)
            storyboard.gotoScene("IAP-scene", "fade", 800)
        end 
    end
    local iapButton = display.newImage("images/buttons/buttonIapmainmenu.png")
    iapButton:setReferencePoint(display.CenterReferencePoint)
    iapButton.x = 304
    iapButton.y = 12
    iapButton:addEventListener("touch", IAPButtonListener)
    group:insert(iapButton)

    local function facebookButtonListener(event)
        if event.phase == "began" and not buttonIsPressed then
            soundEffect:play("button")
            buttonIsPressed = true
            unfreezeButtonTimer = timer.performWithDelay(buttonPressTimeDelay, unfreezeButton)
            -- do something here
        end 
    end
    local facebookButton = display.newImage("images/buttons/buttonFacebook.png")
    facebookButton.x = 280
    facebookButton.y = 60
    facebookButton:addEventListener("touch", facebookButtonListener)
    group:insert(facebookButton)

    gameKeysText = gameKeys.new()
    itemStat["keys"] = gameKeysText
    group:insert(gameKeysText)

    local expBonus = localStorage.get("expBonus")
    local doubleExpImage
    if expBonus > 0 then
        doubleExpImage = display.newImage("images/calendar/calendarExp.png")
        doubleExpImage:setReferencePoint(display.TopLeftReferencePoint)
        doubleExpImage.x = 135
        doubleExpImage.y = 58
        group:insert(doubleExpImage)
    else
        --do nothing
    end
    

    local storyModeScore = localStorage.get("storyLevel")
    local storyModeText = display.newText("", 283, 122, native.systemFont, 9)
    storyModeText.text = storyModeScore
    group:insert(storyModeText)

    local survivalTimeRecord = localStorage.get("survivalRecord")
    local survivalTimeMins = math.floor(survivalTimeRecord/60)
    local survivalTimeSecs = tostring(math.floor(survivalTimeRecord - (survivalTimeMins*60)))
    if (string.len(survivalTimeSecs)) == 1 then survivalTimeSecs = "0" .. survivalTimeSecs end
    local recordText = display.newText("", 285, 150, native.systemFont, 9)
    recordText.text = survivalTimeMins .. ":" .. survivalTimeSecs
    group:insert(recordText)

    local experienceBar = experience.new()
    group:insert(experienceBar)

    local baseDamage = statTable[localStorage.get("charLevel")][3]
    local baseDamageText = display.newText("", 58, 151, native.systemFont, 9)
    baseDamageText.text = baseDamage
    group:insert(baseDamageText)

    local health = statTable[localStorage.get("charLevel")][2]
    local healthText = display.newText("", 219, 95, native.systemFont, 9)
    healthText.text = health
    group:insert(healthText)

    local energyBottle = localStorage.get("energyBottle")
    energyBottleText = display.newText("", 52, 200, native.systemFont, 9)
    energyBottleText.text = energyBottle
    group:insert(energyBottleText)

    local redPot1 = localStorage.get("redPot1")
    local redPot1Text = display.newText("", 98, 200, native.systemFont, 9)
    redPot1Text.text = redPot1
    itemStat["redPot1"] = redPot1Text
    group:insert(redPot1Text)

    local redPot2 = localStorage.get("redPot2")
    local redPot2Text = display.newText("", 145, 200, native.systemFont, 9)
    redPot2Text.text = redPot2
    itemStat["redPot2"] = redPot2Text
    group:insert(redPot2Text)

    local redPot3 = localStorage.get("redPot3")
    local redPot3Text = display.newText("", 191, 200, native.systemFont, 9)
    redPot3Text.text = redPot3
    itemStat["redPot3"] = redPot3Text
    group:insert(redPot3Text)

    local redPot4 = localStorage.get("redPot4")
    local redPot4Text = display.newText("", 238, 200, native.systemFont, 9)
    redPot4Text.text = redPot4
    itemStat["redPot4"] = redPot4Text
    group:insert(redPot4Text)

    local bluePot = localStorage.get("bluePot")
    local bluePotText = display.newText("", 285, 200, native.systemFont, 9)
    bluePotText.text = bluePot
    itemStat["bluePot"] = bluePotText
    group:insert(bluePotText)

    return group
end

local function drawMenuLayout()
    local group = display.newGroup()
    local buttonYTable = {250, 300, 350, 400, 450}

    local function storyButtonListener( event )
        if event.phase == "began" and not buttonIsPressed then
            soundEffect:play("button")
            buttonIsPressed = true
            unfreezeButtonTimer = timer.performWithDelay(buttonPressTimeDelay, unfreezeButton)
            storyboard.gotoScene("story-scene", "fade", 800)
        end 
    end
    local storyButton = widget.newButton{
        defaultFile = "images/buttons/buttonStory.png",
        overFile = "images/buttons/buttonStoryonclick.png",
        onEvent = storyButtonListener
    }
    storyButton.x = display.contentCenterX
    storyButton.y = buttonYTable[1]
    group:insert(storyButton)


    local function survivalButtonListener( event )
        if event.phase == "began" and not buttonIsPressed then
            soundEffect:play("button")
            buttonIsPressed = true
            unfreezeButtonTimer = timer.performWithDelay(buttonPressTimeDelay, unfreezeButton)
            local options = {
                effect = "fade",
                time = 800,
                params = {mode="survival"}
            }
            storyboard.gotoScene("game-scene", options)
        end 
    end
    local survivalButton = widget.newButton{
        defaultFile = "images/buttons/buttonSurvival.png",
        overFile = "images/buttons/buttonSurvivalonclick.png",
        onEvent = survivalButtonListener
    }
    survivalButton.x = display.contentCenterX
    survivalButton.y = buttonYTable[2]
    group:insert(survivalButton)

    local function shopButtonListener(event)
        if event.phase == "began" and not buttonIsPressed then
            soundEffect:play("button")
            buttonIsPressed = true
            unfreezeButtonTimer = timer.performWithDelay(buttonPressTimeDelay, unfreezeButton)
            storyboard.gotoScene("shop-scene", "fade", 800)
        end
    end
    local shopButton = widget.newButton{
        defaultFile = "images/buttons/buttonShop.png",
        overFile = "images/buttons/buttonShoponclick.png",
        onEvent = shopButtonListener,
    }
    shopButton.x = display.contentCenterX
    shopButton.y = buttonYTable[3]
    group:insert(shopButton)


    local function leaderboardButtonListener( event )
        if event.phase == "began" and not buttonIsPressed then
            soundEffect:play("button")
            buttonIsPressed = true
            unfreezeButtonTimer = timer.performWithDelay(buttonPressTimeDelay, unfreezeButton)
            facebookHelper.query("UPDATE_SCORE_AND_CHECK_FRIENDS_SCORE")
            --storyboard.gotoScene("leaderboard-scene", "fade", 800)
        end 
    end
    local leaderboardButton = widget.newButton{
        defaultFile = "images/buttons/buttonLeaderbd.png",
        overFile = "images/buttons/buttonLeaderbdonclick.png",
        onEvent = leaderboardButtonListener
    }
    leaderboardButton.x = display.contentCenterX
    leaderboardButton.y = buttonYTable[4]
    group:insert(leaderboardButton)

    local function luckyDrawButtonListener( event )
        if event.phase == "began" and not buttonIsPressed then
            soundEffect:play("button")
            buttonIsPressed = true
            unfreezeButtonTimer = timer.performWithDelay(buttonPressTimeDelay, unfreezeButton)
            transition.to(menuLayout, {time=600, x=menuXPosn})
            transition.to(chestLayout, {time=600, x=0})
        end 
    end
    local luckyDrawButton = widget.newButton{
        defaultFile = "images/buttons/buttonLucky.png",
        overFile = "images/buttons/buttonLuckyonclick.png",
        onEvent = luckyDrawButtonListener
    }
    luckyDrawButton.x = display.contentCenterX
    luckyDrawButton.y = buttonYTable[5]
    group:insert(luckyDrawButton)

    local function tutorialButtonListener(event)
        if event.phase == "began" and not buttonIsPressed then
            soundEffect:play("button")
            buttonIsPressed = true
            unfreezeButtonTimer = timer.performWithDelay(buttonPressTimeDelay, unfreezeButton)
            storyboard.gotoScene("tutorial-scene", "slideLeft", 800)
        end
    end
    local tutorialButton = widget.newButton{
        defaultFile = "images/buttons/buttonTutorial.png",
        onEvent = tutorialButtonListener
    }
    tutorialButton:setReferencePoint(display.BottomCenterReferencePoint)
    tutorialButton.y = 480
    group:insert(tutorialButton)

    return group
end

local function drawLuckyDrawLayout()
    local group = display.newGroup()
    
    -- draw three chests and background, then position it
    local background = display.newImageRect("images/drawBox.png", 290, 190)
    background:setReferencePoint(display.CenterReferencePoint)
    background.x = display.contentCenterX
    background.y = 320
    group:insert(background)

    local keysNeededTable = {20, 40, 60}
    local keysNeededIndex = 1
    local keysNeededText = display.newText(keysNeededTable[keysNeededIndex], 0, 0, native.systemFont, 9)
    keysNeededText:setReferencePoint(display.CenterReferencePoint)
    keysNeededText.x = display.contentCenterX
    keysNeededText.y = 280
    keysNeededText:setTextColor(255, 255, 255)
    group:insert(keysNeededText)

    local function leftArrowListener(event)
        if event.phase == "began" then
            soundEffect:play("button")
            keysNeededIndex = math.max(1, keysNeededIndex - 1)
            keysNeededText.text = keysNeededTable[keysNeededIndex]
            keysNeededText:setReferencePoint(display.CenterReferencePoint)
            keysNeededText.x = display.contentCenterX
            keysNeededText.y = 280
        end
    end
    local leftArrow = display.newImageRect("images/drawArrow.png", 35, 35)
    leftArrow:setReferencePoint(display.CenterReferencePoint)
    leftArrow.xScale = 1.3
    leftArrow.x = 61
    leftArrow.y = 280
    leftArrow:rotate(180)
    leftArrow:addEventListener("touch", leftArrowListener)
    group:insert(leftArrow)

    local function rightArrowListener(event)
        if event.phase == "began" then
            soundEffect:play("button")
            keysNeededIndex = math.min(#keysNeededTable, keysNeededIndex + 1)
            keysNeededText.text = keysNeededTable[keysNeededIndex]
            keysNeededText:setReferencePoint(display.CenterReferencePoint)
            keysNeededText.x = display.contentCenterX
            keysNeededText.y = 280
        end
    end
    local rightArrow = display.newImageRect("images/drawArrow.png", 35, 35)
    rightArrow:setReferencePoint(display.CenterReferencePoint)
    rightArrow.xScale = 1.3
    rightArrow.x = 260
    rightArrow.y = 280
    rightArrow:addEventListener("touch", rightArrowListener)
    group:insert(rightArrow)

    local threeChests = luckyDraw.new(gameKeysText, keysNeededText, itemStat, soundEffect)
    group:insert(threeChests)

    local function againButtonListener(event)
        if event.phase == "began" and not buttonIsPressed then
            soundEffect:play("button")
            buttonIsPressed = true
            unfreezeButtonTimer = timer.performWithDelay(buttonPressTimeDelay, unfreezeButton)

            threeChests:reset()
        end 
    end
    local againButton = widget.newButton{
        defaultFile = "images/buttons/buttonAgain.png",
        onEvent = againButtonListener,
    }
    againButton.x = display.contentCenterX
    againButton.y = 400
    group:insert(againButton)

    local function backButtonListener(event)
        if event.phase == "began" and not buttonIsPressed then
            soundEffect:play("back")
            buttonIsPressed = true
            unfreezeButtonTimer = timer.performWithDelay(buttonPressTimeDelay, unfreezeButton)

            transition.to(menuLayout, {time=600, x=0})
            transition.to(chestLayout, {time=600, x=chestXPosn})
        end 
    end
    local backButton = widget.newButton{
        defaultFile = "images/buttons/buttonBack.png",
        overFile = "images/buttons/buttonBackonclick.png",
        onEvent = backButtonListener,
    }
    backButton.x = 160
    backButton.y = 450
    group:insert(backButton)
    
    return group
end
---------------------------------------------------------------------------------



-- Called when the scene's view does not exist:
function scene:createScene(event)
    local group = self.view

    soundEffect = mainSoundEffect.new()

    itemStat = {}

    local mainImage = display.newImageRect("images/mainmenu.png", display.contentWidth, display.contentHeight)
    mainImage:setReferencePoint(display.CenterReferencePoint)
    mainImage.x = display.contentCenterX
    mainImage.y = display.contentCenterY
    group:insert(mainImage)

    energyTable = energy.new()
    buttonIsPressed = false

    local topLayout = drawUpperLayout()
    menuLayout = drawMenuLayout()
    chestLayout = drawLuckyDrawLayout()
    --menuLayout:translate(menuXPosn, 0)
    chestLayout:translate(chestXPosn, 0)

    

    group:insert(menuLayout)
    group:insert(topLayout)
    group:insert(chestLayout)
end


-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

    local BGM = require 'gameLogic.backgroundMusic'
    BGM.play("main")
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view

    timer.cancel(energyTable["timer"])
    timer.cancel(unfreezeButtonTimer)
    unfreezeButtonTimer = nil
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view

    
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
    local group = self.view

    soundEffect:dispose()
    soundEffect = nil

    itemStat = nil
    energyBottleText = nil
    gameKeysText = nil
    buttonIsPressed = nil

    chestLayout:removeSelf()
    chestLayout = nil
    menuLayout:removeSelf()
    menuLayout = nil
    print("destroy lobbyScene: " .. group.numChildren)
    group:removeSelf()
    print("destroy lobbyScene: " .. group.numChildren)
    energyTable = nil
    group = nil
    self.view = nil
end


-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene

end


-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene

end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )
-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )
-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )
-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )
-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )
-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )
-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )
-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )
---------------------------------------------------------------------------------

return scene