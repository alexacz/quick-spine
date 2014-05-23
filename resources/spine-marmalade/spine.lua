-------------------------------------------------------------------------------
-- Spine Runtimes Software License
-- Version 2.1
-- 
-- Copyright (c) 2013, Esoteric Software
-- All rights reserved.
-- 
-- You are granted a perpetual, non-exclusive, non-sublicensable and
-- non-transferable license to install, execute and perform the Spine Runtimes
-- Software (the "Software") solely for internal use. Without the written
-- permission of Esoteric Software (typically granted by licensing Spine), you
-- may not (a) modify, translate, adapt or otherwise create derivative works,
-- improvements of the Software or develop new applications using the Software
-- or (b) remove, delete, alter or obscure any trademarks or any copyright,
-- trademark, patent or other intellectual property or proprietary rights
-- notices on or in the Software, including any copy thereof. Redistributions
-- in binary or source form must include this license and terms.
-- 
-- THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
-- IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
-- EVENT SHALL ESOTERIC SOFTARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------

spine = {}
 
spine.utils = require "spine-lua.utils"
spine.SkeletonJson = require "spine-lua.SkeletonJson"
spine.SkeletonData = require "spine-lua.SkeletonData"
spine.BoneData = require "spine-lua.BoneData"
spine.SlotData = require "spine-lua.SlotData"
spine.Skin = require "spine-lua.Skin"
spine.RegionAttachment = require "spine-lua.RegionAttachment"
spine.Skeleton = require "spine-lua.Skeleton"
spine.Bone = require "spine-lua.Bone"
spine.Slot = require "spine-lua.Slot"
spine.AttachmentType = require "spine-lua.AttachmentType"
spine.AttachmentLoader = require "spine-lua.AttachmentLoader"
spine.Animation = require "spine-lua.Animation"
spine.AnimationStateData = require "spine-lua.AnimationStateData"
spine.AnimationState = require "spine-lua.AnimationState"
spine.EventData = require "spine-lua.EventData"
spine.Event = require "spine-lua.Event"
spine.SkeletonBounds = require "spine-lua.SkeletonBounds"

spine.utils.readFile = function (fileName, base)
	base = "" or base
	local path = base .. fileName
	local file = io.open(path, "r")
	if not file then return nil end
	local contents = file:read("*a")
	io.close(file)
	return contents
end
 
--
-- JSON decode implementation
-- 
local json = require "spine-marmalade.dkjson"
spine.utils.readJSON = function (text)
	return json.decode(text)
end
 
spine.Skeleton.failed = {} -- Placeholder for an image that failed to load.
 
spine.Skeleton.new_super = spine.Skeleton.new

function spine.Skeleton.new(skeletonData)
	
	local self = spine.Skeleton.new_super(skeletonData)

	if not self.images then self.images = {} end
	local images = self.images

	-- Customizes where images are found.
	function self:createImage (attachment)
		self.sourceFolder = self.sourceFolder or ""
		local fname = self.sourceFolder..attachment.name..".png"
		--dbg.print("self:createImage "..fname)
		return director:createSprite({source = fname})
	end

	-- Customizes what happens when an image changes, return false to recreate the image.
	function self:modifyImage (attachment)
		return false
	end

	-- updateWorldTransform positions images.
	local updateWorldTransform_super = self.updateWorldTransform
	
	function self:updateWorldTransform ()
	
		updateWorldTransform_super(self)

		local images = self.images
		local skeletonR, skeletonG, skeletonB, skeletonA = self.r, self.g, self.b, self.a
		
		for i,slot in ipairs(self.drawOrder) do
			if slot.attachment and slot.attachment.type == spine.AttachmentType.region then
				local attachment = slot.attachment			
				local image = self.images[slot.attachment]
				
				if not image then 
					image = self:createImage(slot.attachment) 
					
					image.xScaleRatio = slot.attachment.width / image.w
					image.yScaleRatio = slot.attachment.height / image.h
					
					image.xAnchor = 0.5
					image.yAnchor = 0.5
					
					self.images[slot.attachment] = image
					self.attachments = attachment
					--self:addChild(image)	
				end
				
				if image then
					
					image.x = self.x + slot.bone.worldX + slot.attachment.x * slot.bone.m00 + slot.attachment.y * slot.bone.m01
					image.y = self.y + slot.bone.worldY + slot.attachment.x * slot.bone.m10 + slot.attachment.y * slot.bone.m11
					image.rotation = -(slot.bone.worldRotation + slot.attachment.rotation)
										
					image.xScale =  (slot.bone.worldScaleX + attachment.scaleX - 1) * image.xScaleRatio
					image.yScale =  (slot.bone.worldScaleY + attachment.scaleY - 1) * image.yScaleRatio
										
					if self.flipX then
						image.rotation = -image.rotation
						image.xFlip = true
					end
					
					if self.flipY then
						image.rotation = -image.rotation
						image.yFlip = true
					end

					--image.color = {slot.r, slot.g, slot.b, slot.a}
					--[[
					local skeletonR, skeletonG, skeletonB, skeletonA = self.r, self.g, self.b, self.a
					local r, g, b = skeletonR * slot.r, skeletonG * slot.g, skeletonB * slot.b
					if image.lastR ~= r or image.lastG ~= g or image.lastB ~= b or not image.lastR then
						image.color = {r, g, b}
						image.lastR, image.lastG, image.lastB = r, g, b
					end
					local a = skeletonA * slot.a
					if a and (image.lastA ~= a or not image.lastA) then
						image.lastA = a
						image.alpha = image.lastA -- 0-1 range, unlike RGB.
					end
					--]]
					
					if slot.data.additiveBlending then
						--image.blendMode = "add"
					end
					
				end
			end
		end
		
		
	end
	
	return self
end

return spine
