if SERVER then
	
	local files = file.Find( 'sv/*.lua', 'LUA' )
	table.foreach( files, function( key, gui )
		include( 'sv/' .. gui )
	end )
	
	local files = file.Find( 'cl/*.lua', 'LUA' )
	table.foreach( files, function( key, gui )
		AddCSLuaFile( 'cl/' .. gui )
	end )
	
end
	
	
if CLIENT then

	local files = file.Find( 'cl/*.lua', 'LUA' )
	table.foreach( files, function( key, gui )
		include( 'cl/' .. gui )
	end )
	
end

print('Scoreboard loaded!')