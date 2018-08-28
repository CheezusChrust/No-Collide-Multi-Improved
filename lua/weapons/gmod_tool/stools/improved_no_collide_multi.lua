--Tool created by Cheezus, with some code taken from PTuga's Smart No-Collide because I'm a lazy fuck

TOOL.Category		= "Constraints"
TOOL.Name			= "#No-Collide Multi Improved"
TOOL.Command		= nil
TOOL.ConfigName		= nil
TOOL.SelectedEntities = {}
TOOL.SelectColor = Color(0, 255, 0, 255)
TOOL.ClientConVar[ "distance" ] = "1.5"
TOOL.ClientConVar[ "maxnocollides" ] = "512"
TOOL.ClientConVar[ "dumb" ] = "0"
TOOL.Smack = {
	"Thats a lotta constraints. Why do you need dumb on?",
	"Is that amount of constraints REALLY necessary?",
	"Wow. Consider disabling dumb because it creates (n^2)/2 contraints.",
	"Geez. Even your mom doesnt have that many constraints."
}

if (CLIENT) then
	language.Add("tool.improved_no_collide_multi.name", "No-Collide Multi Improved")
	language.Add("tool.improved_no_collide_multi.desc", "Ignores collisions between multiple entities while saving on constraint count.")
	language.Add("tool.improved_no_collide_multi.0", "Primary: Select or unselect an entity. Hold E to get all constrained objects.  Secondary: Apply no collide to selected objects.  Reload: Clear selection.")
	language.Add("tool.improved_no_collide_multi.distance", "Distance:")
	language.Add("tool.improved_no_collide_multi.distance.help", "Distance scales the hitbox of objects by a certain amount when determining if they're intersecting or near eachother. Lower means less constraints, but a higher chance of props colliding. Higher means more constraints, but more more 'play' is allowed between props.")
	language.Add("tool.improved_no_collide_multi.maxnocollides", "Max No-Collides:")
	language.Add("tool.improved_no_collide_multi.maxnocollides.help", "The maximum number of constraints allowed to be created before the tool complains to you.")
	language.Add("tool.improved_no_collide_multi.dumb", "Dumb No-Collide")
	language.Add("tool.improved_no_collide_multi.dumb.help", "Turning this on disables the 'Improved' portion of this tool, thus I recommend keeping this OFF. Turn this on and enjoy (n^2)/2 constraints.")
end

function intersection1d(box1,box2)
    return math.max(box1.max,box1.min) >= math.min(box2.min,box2.max) and math.max(box2.max,box2.min) >= math.min(box1.min,box1.max)
end

function intersection3d(e1,e2,sizeMul)
	local e1_AABBMins,e1_AABBMaxs = e1:GetRotatedAABB(e1:OBBMins(),e1:OBBMaxs())
	local e2_AABBMins,e2_AABBMaxs = e2:GetRotatedAABB(e2:OBBMins(),e2:OBBMaxs())
    local box1 = {
        x = {
            min = (e1:GetPos() + e1_AABBMins*sizeMul).x,
            max = (e1:GetPos() + e1_AABBMaxs*sizeMul).x
        },
        y = {
            min = (e1:GetPos() + e1_AABBMins*sizeMul).y,
            max = (e1:GetPos() + e1_AABBMaxs*sizeMul).y
        },
        z = {
            min = (e1:GetPos() + e1_AABBMins*sizeMul).z,
            max = (e1:GetPos() + e1_AABBMaxs*sizeMul).z
        }
    }
    local box2 = {
        x = {
            min = (e2:GetPos() + e2_AABBMins*sizeMul).x,
            max = (e2:GetPos() + e2_AABBMaxs*sizeMul).x
        },
        y = {
            min = (e2:GetPos() + e2_AABBMins*sizeMul).y,
            max = (e2:GetPos() + e2_AABBMaxs*sizeMul).y
        },
        z = {
            min = (e2:GetPos() + e2_AABBMins*sizeMul).z,
            max = (e2:GetPos() + e2_AABBMaxs*sizeMul).z
        }
    }
    return intersection1d(box1.x,box2.x) and intersection1d(box1.y,box2.y) and intersection1d(box1.z,box2.z)
end

local function notifyPlayer( Player, Message, Type )
	Player:SendLua( "GAMEMODE:AddNotify( '" .. Message .. "', " .. Type .. ", 5 );" )
end

--local function undoNoCollide( Player, Constraint )
local function undoMultiNoCollide( Player, Tbl )
	undo.Create( "Multi No-Collide" )
		undo.AddFunction( function( tab, arg2 )
			for _,Constraint in pairs( Tbl ) do
				if Constraint and Constraint:IsValid( ) then
					Constraint:Input( "EnableCollisions", nil, nil, nil )
					Constraint:Remove( )
					Value = nil -- Just to make sure;
				end
			end
		end )
		undo.SetPlayer( Player )
		undo.SetCustomUndoText( "Undone Multi No-Collide" )
	undo.Finish( )
	
	--Player:AddCleanup( "Multi No-Collide", Constraint )
end

function TOOL:isReallyValid( Entity )
	if Entity and Entity:IsValid( ) and not Entity:IsPlayer( ) and not Entity:IsWorld( ) and not Entity:IsRagdoll( ) and not Entity:IsNPC( ) then return true end
	return false
end

function TOOL:isSelected( Entity )
	return ( self.SelectedEntities[Entity] and true or false )
end

function TOOL:selectedIt( Entity )
	local EntityColor = Entity:GetColor()
	
	self.SelectedEntities[ Entity ] = EntityColor
	
	Entity:SetColor( self.SelectColor )
end

function TOOL:deselectedIt( Entity )
	local EntityColor = self.SelectedEntities[ Entity ]
	
	self.SelectedEntities[ Entity ] = nil

	Entity:SetColor( EntityColor )
end

function TOOL:deselectAll( )
	for Entity, _ in pairs ( self.SelectedEntities ) do
		if self:isReallyValid( Entity) then
			if self.SelectedEntities[ Entity ] then self:deselectedIt( Entity ) end
		end
	end
end

--Tool stuff

function TOOL:LeftClick( trace )
	if CLIENT then return true end

	local Entity = trace.Entity
	local Owner = self:GetOwner( )
	
	if not self:isReallyValid( Entity ) then return end

	local KeyUse = self:GetOwner( ):KeyDown( IN_USE )
	
	if not KeyUse then
		if not self:isSelected( Entity ) then self:selectedIt( Entity ) else self:deselectedIt( Entity ) end
	else
		local ConstraintedEntities = constraint.GetAllConstrainedEntities( Entity )
		local Count = 0
		
		for Entity, _ in pairs( ConstraintedEntities ) do
			if not self:isSelected( Entity ) and self:isReallyValid( Entity ) then
				self:selectedIt( Entity )
				
				Count = Count + 1
			end
		end
		
		notifyPlayer( Owner, "Selected " .. Count .. " Props", "NOTIFY_GENERIC" )
	end
	
	return true
end

function TOOL:RightClick( trace )
	if CLIENT then return end

	if table.Count( self.SelectedEntities ) == 0 then return false end

	local Owner = self:GetOwner( )
	local Distance = math.Clamp( self:GetClientNumber( "distance" ), 1, 3 )
	local Undo = self:GetClientNumber( "undo" )
	local Dumb = self:GetClientNumber( "dumb" )
	local MaxNoCollides = math.Clamp( self:GetClientNumber( "maxnocollides" ), 1, 2048 )
	local NoCollidedTo = {}
	local Constraints = {}

	if table.Count( self.SelectedEntities ) == 1 then
		notifyPlayer( Owner, "Only one prop was selected. The hell do you want me to do with it, no-collide it to itself or something?", "NOTIFY_GENERIC" )
		for Entity, _ in pairs ( self.SelectedEntities ) do
			if self:isReallyValid( Entity) then self:deselectedIt( Entity ) end
		end
		return false
	end

	print((table.Count( self.SelectedEntities )^2)/2)
	print(MaxNoCollides)
	if Dumb == 1 and (table.Count( self.SelectedEntities )^2)/2 > MaxNoCollides then
		notifyPlayer( Owner, "WARNING: Constraint count will exceed max allowed constraints (" .. math.floor((table.Count( self.SelectedEntities )^2)/2) .. ">" .. MaxNoCollides .. ")! Increase the limit, deselect dumb, or select fewer props!", "NOTIFY_GENERIC")
		return false
	end

	local n = 0
	for Entity, _ in pairs( self.SelectedEntities ) do
		for Entity2, _ in pairs( self.SelectedEntities ) do
			if (NoCollidedTo[Entity] == Entity2 or NoCollidedTo[Entity2] == Entity) and Dumb == 0 then break end
			if (Entity == Entity2) == false then
				if self:isReallyValid( Entity ) and self:isReallyValid( Entity2 ) and (intersection3d( Entity, Entity2, Distance ) or Dumb == 1) and n < MaxNoCollides then
					NoCollidedTo[Entity] = Entity2
					NoCollidedTo[Entity2] = Entity
					table.insert( Constraints, constraint.NoCollide( Entity, Entity2, 0, 0 ) )
					n = n + 1
				end
			end
		end
	end

	if n > MaxNoCollides-1 then
		notifyPlayer( Owner, "WARNING: Could not create amount of constraints required! Increase the constraint limit!", "NOTIFY_GENERIC" )
		for _,Constraint in pairs( Constraints ) do
			if Constraint and Constraint:IsValid( ) then
				Constraint:Input( "EnableCollisions", nil, nil, nil )
				Constraint:Remove( )
				Value = nil
			end
		end
		return false
	end

	if n > 0 then undoMultiNoCollide( Owner, Constraints ) end
	
	if n == 0 then
		notifyPlayer( Owner, "No props were no-collided! It seems like all of your entities are too far apart. Try increasing the distance setting if needed.", "NOTIFY_GENERIC" )
		self:deselectAll()
	else
		if Dumb == 1 and n > 200 then
			notifyPlayer( Owner, "No-Collided selected entities using " .. math.floor(n/2) .. " constraints. " .. self.Smack[math.random( 1, table.Count( self.Smack ) )], "NOTIFY_GENERIC" )
		else
			notifyPlayer( Owner, "No-Collided selected entities using " .. n .. " constraints", "NOTIFY_GENERIC" )
		end
		self:deselectAll()
	end

	self.SelectedEntities = { }
end

function TOOL:Reload( trace )
	if ( table.Count( self.SelectedEntities ) == 0 ) then return end

	local Owner = self:GetOwner( )

	self:deselectAll()
	
	self.SelectedEntities = { }
	
	notifyPlayer( Owner, "Selection Cleared", "NOTIFY_CLEANUP" )
	
	return true
end

function TOOL.BuildCPanel(cp)
    cp:AddControl("Header", {Text = "#tool.improved_no_collide_multi.name", Description = "#tool.improved_no_collide_multi.desc"})

	cp:AddControl("Slider", {
	    Label = "#tool.improved_no_collide_multi.distance",
		Type = "Float",
	    Min = "1",
	    Max = "3",
	    Command = "improved_no_collide_multi_distance",
		Help = true
	})
	cp:AddControl("Slider", {
	    Label = "#tool.improved_no_collide_multi.maxnocollides",
	    Min = "256",
	    Max = "2048",
	    Command = "improved_no_collide_multi_maxnocollides",
		Help = true
	})
	cp:AddControl("CheckBox", {
		Label = "#tool.improved_no_collide_multi.dumb",
		Command = "improved_no_collide_multi_dumb",
		Help = true
	})
end