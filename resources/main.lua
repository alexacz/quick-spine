-- Your app starts here!
print("This is my app!")

-- create scene
director:createScene()

local spine = require "spine-marmalade.spine"

dbg.print("Loading json data...")
local json = spine.SkeletonJson.new()
json.scale = 1

local skeletonData = json:readSkeletonDataFile("assets/spineboy/spineboy.json")
--local skeletonData = json:readSkeletonDataFile("assets/goblins/goblins.json")
--local skeletonData = json:readSkeletonDataFile("assets/dragon/dragon.json")

dbg.print("Creating skeleton...")
local skeleton = spine.Skeleton.new(skeletonData)

skeleton.sourceFolder = "assets/spineboy/images/"
--skeleton.sourceFolder = "assets/goblins/images/"
--skeleton.sourceFolder = "assets/dragon/images/"
skeleton.x = director.displayCenterX
skeleton.y = director.displayCenterY - 100
skeleton.flipX = true
skeleton.flipY = false
skeleton.debug = true -- Omit or set to false to not draw debug lines on top of the images.
--skeleton:setSkin("goblingirl")
skeleton:setToSetupPose()

dbg.print("Creating skeleton bounds...")
local bounds = spine.SkeletonBounds.new()

-- AnimationStateData defines crossfade durations between animations.
local stateData = spine.AnimationStateData.new(skeletonData)
stateData:setMix("walk", "jump", 0.2)
stateData:setMix("jump", "walk", 0.4)

-- AnimationState has a queue of animations and can apply them with crossfading.
local state = spine.AnimationState.new(stateData)
state:setAnimationByName(0, "drawOrder")
state:addAnimationByName(0, "jump", false, 0)
state:addAnimationByName(0, "walk", true, 0)
--state:setAnimationByName(0, "flying", true, 0)

state.onStart = function (trackIndex)
	print(trackIndex.." start: "..state:getCurrent(trackIndex).animation.name)
end
state.onEnd = function (trackIndex)
	print(trackIndex.." end: "..state:getCurrent(trackIndex).animation.name)
end
state.onComplete = function (trackIndex, loopCount)
	print(trackIndex.." complete: "..state:getCurrent(trackIndex).animation.name..", "..loopCount)
end
state.onEvent = function (trackIndex, event)
	print(trackIndex.." event: "..state:getCurrent(trackIndex).animation.name..", "..event.data.name..", "..event.intValue..", "..event.floatValue..", '"..(event.stringValue or "").."'")
end

local lastTime = 0

system:addEventListener("update", function (event)

	-- Compute time in seconds since last frame.
	local currentTime = event.time / 1000
	local delta = currentTime - lastTime
	lastTime = currentTime

	-- Update the state with the delta time, apply it, and update the world transforms.
	state:update(delta)
	state:apply(skeleton)
	skeleton:updateWorldTransform()

end)
