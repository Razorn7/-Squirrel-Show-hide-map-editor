Editing <- false;
Deleted <- false;

SelectedObject <- null;
BACKSPACE <- KeyBind(0x08)
INSERT <- KeyBind(0x2D)
DELETE <- KeyBind(0x2E)

function Server::ServerData(stream)
{
	local int = stream.ReadInt();
	local str = stream.ReadString();
	switch (int)
	{
		case 0:
			::Editing = true;
		break;
		case 1:
			::Editing = false;
		break;
	}
}
	
function Player::PlayerShoot( player, weapon, hitEntity, hitPosition )
{
	if (hitEntity && hitEntity.Type == OBJ_BUILDING && SelectedObject == null && Editing == true)
	{
		local data = Stream();
		data.WriteInt(3);
		data.WriteString("");
		Server.SendData(data);
		Console.Print("Object has been selected. ID: " + hitEntity.ModelIndex)
		Console.Print("Warning: Don't press [BACKSPACE] if you're not sure to hide this object.");
		::SelectedObject = hitEntity;
		::Deleted = false;
	}
	else if (hitEntity && hitEntity.Type == OBJ_BUILDING && SelectedObject != null && Editing == true) Console.Print("You already have an object selected, press [BACKSPACE] to stop editing the object.");
}
	
function KeyBind::OnDown(key)
{
	switch (key)
	{
		case DELETE: //HIDE
			if (Deleted == false)
			{
				local data = Stream();
				data.WriteInt(1);
				data.WriteString(SelectedObject.ModelIndex + "\n" + SelectedObject.Position.X + "\n" + SelectedObject.Position.Y + "\n" + SelectedObject.Position.Z);
				Server.SendData(data);
				::Deleted = true;
			}
			else Console.Print("The obect is already hidden.");
		break;
		case INSERT: //SHOW
			if (Deleted == true)
			{
				local data = Stream();
				data.WriteInt(2);
				data.WriteString(SelectedObject.ModelIndex + "\n" + SelectedObject.Position.X + "\n" + SelectedObject.Position.Y + "\n" + SelectedObject.Position.Z);
				Server.SendData(data);
				::Deleted = false;
			}
			else Console.Print("The obect is already shown.");
		break;
		case BACKSPACE:
			local data = Stream();
			data.WriteInt(4);
			data.WriteString(SelectedObject.ModelIndex + "\n" + SelectedObject.Position.X + "\n" + SelectedObject.Position.Y + "\n" + SelectedObject.Position.Z);
			Server.SendData(data);
			::SelectedObject = null;
			Console.Print("Editing has been stopped.", player);
		break;
	}
}

function Script::ScriptLoad()
{
	Console.Print("Editor has been loaded.");
}