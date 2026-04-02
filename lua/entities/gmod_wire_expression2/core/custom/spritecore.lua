--[[

	Sprite Core E2 Extension
	by NickMBR

	Release Date: 02/12/2016

]]--

-- HEADER --
E2Lib.RegisterExtension("spritecore", false, "Create and Control Sprites with E2")

-- CONVARS --
local wire_spritecore_max = CreateConVar("wire_spritecore_max", "100", FCVAR_ARCHIVE)
local wire_spritecore_maxscale = CreateConVar("wire_spritecore_maxscale", "16", FCVAR_ARCHIVE)

local textures = {
	"sprites/light_glow03.vmt",
	"sprites/animglow01.vmt",
	"sprites/blueflare1.vmt",
	"sprites/blueglow1.vmt",
	"sprites/flare1.vmt",
	"sprites/glow01.spr",
	"sprites/glow02.vmt",
	"sprites/glow03.vmt",
	"sprites/glow04.vmt",
	"sprites/glow06.vmt",
	"sprites/glow07.vmt",
	"sprites/glow08.vmt",
	"sprites/halo01.vmt",
	"sprites/lamphalo.vmt",
	"sprites/light_ignorez.vmt",
	"sprites/light_glow01.vmt",
	"sprites/light_glow02.vmt",
	"sprites/light_glow03.vmt",
	"sprites/redglow2.vmt",
	"sprites/redglow4.vmt",
	"sprites/fire.vmt",
	"sprites/fire1.vmt",
	"sprites/fire2.vmt",
}

local rendermodes = {
	"0 = Normal",
	"1 = Color",
	"2 = Texture",
	"3 = Glow",
	"4 = Solid",
	"5 = Additive",
	"7 = Additive Fractional",
	"8 = Alpha Add",
	"9 = World Glow",
	"10 = Don't Render",
	"Default Render is 9 (World Glow).",
}

-- CHECK FUNCTIONS --
local function canSpawnSprite(self)
	return self.data.sprite_count < wire_spritecore_max:GetInt()
end

local function getSprite(self, index)
	return self.data.sprites[index]
end

local function checkPath(path)
	if not string.match(path, "%.vmt$") then
		path = path .. ".vmt"
	end
	return path
end

local color_white = Vector(255, 255, 255)

-- SPRITE CREATOR --
local function CreateSprite(self, index, path, pos, color, alpha, scale, parent, rendermode, framerate)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end

	-- Sets a default sprite in case fields are nil
	if not path then path = "sprites/glow02.vmt" end
	if not pos then pos = self.entity:GetPos() end
	if not color then color = color_white end
	if not alpha then alpha = 255 end
	if not scale then scale = 1 end
	if not parent or not E2Lib.isOwner(self, parent) then parent = self.entity end
	if not rendermode then rendermode = 9 end
	if not framerate then framerate = 10 end

	-- Sets a maximum sprite scale
	if scale > wire_spritecore_maxscale:GetInt() then scale = wire_spritecore_maxscale:GetInt() end

	-- Creates it
	local spr = ents.Create("env_sprite")
	if not IsValid(spr) then return end

	self.data.sprites[index] = spr
	self.data.sprite_count = self.data.sprite_count + 1

	spr:CallOnRemove("wire_expression2_spritecore_remove", function()
		self.data.sprites[index] = nil
		self.data.sprite_count = math.max(self.data.sprite_count - 1, 0)
	end)

	E2Lib.setPos(spr, pos)
	spr:SetMoveType(MOVETYPE_NONE)

	spr:SetSaveValue("model", checkPath(path))
	spr:SetSaveValue("rendercolor", string.format("%i %i %i", color.x, color.y, color.z))
	spr:SetKeyValue("renderamt", alpha)
	spr:SetSaveValue("scale", scale)
	spr:SetSaveValue("rendermode", rendermode)
	spr:SetSaveValue("framerate", framerate)

	spr:Spawn()
	spr:Activate()
	spr:SetParent(parent)

	return spr
end

-- SPRITE REMOVER --
local function spriteRemoveAll(self)
	local tbl = self.data.sprites
	for _, v in pairs(self.data.sprites) do
		if IsValid(v) then v:Remove() end
	end
end

-- E2 FUNCTIONS --

__e2setcost(1)

e2function number spriteCanCreate()
	if canSpawnSprite(self) then
		return 1
	end
	return 0
end

-- SPRITE CREATOR ALL --
-- Args: Index, Path, Pos, Color, Alpha, Scale, Parent, RenderMode, Framerate

__e2setcost(20)

-- SPRITE SPAWN FULL ARGS --
e2function entity spriteSpawn(index, string path, vector pos, vector color, alpha, scale, entity parent, rendermode, framerate)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end
	if getSprite(self, index) then return end

	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])

	return CreateSprite(self, index, path, pos, color, alpha, scale, parent, rendermode, framerate)
end

-- SPRITE SPAWN NO FRAMERATE --
e2function entity spriteSpawn(index, string path, vector pos, vector color, alpha, scale, entity parent, rendermode)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end
	if getSprite(self, index) then return end

	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])

	return CreateSprite(self, index, path, pos, color, alpha, scale, parent, rendermode)
end

-- SPRITE SPAWN NO RENDERMODE --
e2function entity spriteSpawn(index, string path, vector pos, vector color, alpha, scale, entity parent)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end
	if getSprite(self, index) then return end

	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])

	return CreateSprite(self, index, path, pos, color, alpha, scale, parent)
end

-- SPRITE SPAWN NO PARENT --
e2function entity spriteSpawn(index, string path, vector pos, vector color, alpha, scale)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end
	if getSprite(self, index) then return end

	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])

	return CreateSprite(self, index, path, pos, color, alpha, scale)
end

-- SPRITE SPAWN NO SCALE --
e2function entity spriteSpawn(index, string path, vector pos, vector color, alpha)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end
	if getSprite(self, index) then return end

	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])

	return CreateSprite(self, index, path, pos, color, alpha)
end

-- SPRITE SPAWN NO ALPHA --
e2function entity spriteSpawn(index, string path, vector pos, vector color)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end
	if getSprite(self, index) then return end

	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])

	return CreateSprite(self, index, path, pos, color)
end

-- SPRITE SPAWN NO COLOR --
e2function entity spriteSpawn(index, string path, vector pos)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end
	if getSprite(self, index) then return end

	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])

	return CreateSprite(self, index, path, pos)
end

-- SPRITE SPAWN NO POS --
e2function entity spriteSpawn(index, string path)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end
	if getSprite(self, index) then return end

	return CreateSprite(self, index, path)
end

-- SPRITE SPAWN ONLY INDEX --
e2function entity spriteSpawn(index)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end
	if getSprite(self, index) then return end

	return CreateSprite(self, index)
end

e2function entity spriteDeleteAll()
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	
	spriteRemoveAll(self)
end

__e2setcost(10)

-- SPRITE REMOVE --
e2function entity spriteDelete(index)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	
	local spr = getSprite(self, index)
	if IsValid(spr) then spr:Remove() end
end

-- SPRITE TOGGLE --
e2function void spriteEnable(index, value)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end

	local spr = getSprite(self, index)
	if IsValid(spr) then spr:SetNoDraw(value ~= 1) end
end

-- SPRITE SET POS --
e2function void spriteSetPos(index, vector pos)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end

	pos = Vector(pos[1], pos[2], pos[3])

	local spr = getSprite(self, index)
	if IsValid(spr) then E2Lib.setPos(spr, pos) end
end

-- SPRITE SET COLOR --
e2function void spriteSetColor(index, vector color)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end

	local spr = getSprite(self, index)
	if IsValid(spr) then spr:SetKeyValue("rendercolor", string.format("%i %i %i", color[1], color[2], color[3])) end
end

-- SPRITE SET COLOR WITH ALPHA --
e2function void spriteSetColor(index, vector color, alpha)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end

	local spr = getSprite(self, index)
	if IsValid(spr) then
		spr:SetKeyValue("rendercolor", string.format("%i %i %i", color[1], color[2], color[3]))
		spr:SetKeyValue("renderamt", alpha)
	end
end

-- SPRITE SET COLOR WITH VEC4 --
e2function void spriteSetColor(index, vector4 color)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end

	local spr = getSprite(self, index)
	if IsValid(spr) then
		spr:SetKeyValue("rendercolor", string.format("%i %i %i", color[1], color[2], color[3]))
		spr:SetKeyValue("renderamt", color[4])
	end
end

-- SPRITE SET ALPHA --
e2function void spriteSetAlpha(index, alpha)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end

	local spr = getSprite(self, index)
	if IsValid(spr) then spr:SetKeyValue("renderamt", alpha) end
end

-- SPRITE SET SCALE --
e2function void spriteSetScale(index, scale)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end

	local spr = getSprite(self, index)
	if IsValid(spr) then
		if scale > wire_spritecore_maxscale:GetInt() then scale = wire_spritecore_maxscale:GetInt() end
		spr:SetKeyValue("scale", scale)
	end
end

-- SPRITE SET PARENT --
e2function void spriteSetParent(index, entity parent)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end

	local spr = getSprite(self, index)
	if IsValid(spr) and IsValid(parent) then spr:SetParent(parent) end
end

-- SPRITE SET RENDERMODE --
e2function void spriteSetRendermode(index, rendermode)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end

	local spr = getSprite(self, index)
	if IsValid(spr) then spr:SetKeyValue("rendermode", rendermode) end
end

-- SPRITE SET FRAMERATE --
e2function void spriteSetFramerate(index, framerate)
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not canSpawnSprite(self) then return end

	local spr = getSprite(self, index)
	if IsValid(spr) then spr:SetKeyValue("framerate", framerate) end
end

-- PRINT AVALIABLE SPRITE LIST --
e2function void spriteList()
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not textures then return end

	self.player:ChatPrint("Sprite List:")
	for _, v in ipairs(textures) do
		self.player:ChatPrint(v)
	end

	self.player:ChatPrint("[SpriteCore] Open the chat to see the texture list above.")
end

-- PRINT RENDER MODES LIST --
e2function void spriteRList()
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not textures then return end

	self.player:ChatPrint("Render Modes:")
	for _, v in ipairs(rendermodes) do
		self.player:ChatPrint(v)
	end

	self.player:ChatPrint("[SpriteCore] Open the chat to see the render modes list above.")
end

-- CALLBACKS --
registerCallback("construct", function(self)
	self.data.sprites = {}
	self.data.sprite_count = 0
end)

registerCallback("destruct", function(self)
	spriteRemoveAll(self)
end)
