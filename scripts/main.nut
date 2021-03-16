class CEdit
{
	Logged = false;
	Selected = false;
}

function onScriptLoad()
{
	Count <- 0;
	EditMode <- array(GetMaxPlayers(), null);
	EditDB <- ConnectSQL("Database.db");
	
	QuerySQL(EditDB, "CREATE TABLE IF NOT EXISTS Objects (StaticID INTEGER, ObjectID INTEGER, Position TEXT)");
	
	print("Loaded In-game building show/hide editor by Razor. (v1.0)");
	
	HideObjects();
}

function onPlayerJoin(player)
{
	EditMode[player.ID] = CEdit();
}

function onPlayerCommand(player, cmd, text)
{
	if (cmd == "editmode")
	{
		if (!text) PrivMessage(player, "/" + cmd + " <on/off>");
		else if (text == "on")
		{
			if (EditMode[player.ID].Logged == true) PrivMessage(player, "You're already in edit mode.");
			else
			{
				EditMode[player.ID].Logged = true;
				PrivMessage(player, "Edit mode has been enabled.");
				player.SetWeapon(32, 9999);
				PrivMessage(player, "M60 has been loaded with 9999 ammo.");
				SendDataToClient(player, 0, "");
			}
		}
		else if (text == "off")
		{
			if (EditMode[player.ID].Selected) PrivMessage(player, "You can't turn edit mode as \"off\" with an selected object.");
			else if (EditMode[player.ID].Logged == false) PrivMessage(player, "You're not in edit mode.");
			else
			{
				EditMode[player.ID].Logged = false;
				player.Disarm();
				PrivMessage(player, "Edit mode has been disabled.");
				SendDataToClient(player, 1, "");
			}
		}
		else PrivMessage(player, "Invalid option.");
	}
}

function onClientScriptData(player)
{
	local int = Stream.ReadInt(),
	str = Stream.ReadString();
	//PrivMessage(player, str)
	switch (int)
	{
		case 1: // HIDE OBJECT
			if (EditMode[player.ID].Logged == false) return;
			else
			{
				local s = split(str, "\n");
				local q = QuerySQL(EditDB, "SELECT * FROM Objects");
				local id = Count + 1;
				QuerySQL(EditDB, "INSERT INTO Objects (StaticID, ObjectID, Position) VALUES ('" + id + "', '" + s[0].tointeger() + "', '" + s[1] + "," + s[2] + "," + s[3] + "')");
				HideMapObject( s[0].tointeger(), s[1].tofloat(), s[2].tofloat(), s[3].tofloat() );
				PrivMessage(player, "The object has been hidden.");
				Count ++;
			}
		break;
		case 2: // SHOW OBJECT
			if (EditMode[player.ID].Logged == false) return;
			else
			{
				local s = split(str, "\n");
				local q = QuerySQL(EditDB, "SELECT * FROM Objects");
				local id = Count;
				QuerySQL(EditDB, "DELETE FROM Objects WHERE StaticID='" + id + "'");
				ShowMapObject( s[0].tointeger(), s[1].tofloat(), s[2].tofloat(), s[3].tofloat() );
				PrivMessage(player, "The object has been shown.");
				Count --;
			}
		break;
		case 3:
			if (EditMode[player.ID].Selected == false) EditMode[player.ID].Selected = true;
		break;
		case 4:
			if (EditMode[player.ID].Selected == true) EditMode[player.ID].Selected = false;
		break;
	}
}

function SendDataToClient(player, integer, string)
{
	Stream.StartWrite();
	Stream.WriteInt(integer);
	if (string != null) Stream.WriteString(string);
	Stream.SendStream(player);
}

function HideObjects()
{
    local q = ::QuerySQL(EditDB, "SELECT * FROM Objects"), i = 0;
    if (q)
	{
		while (::GetSQLColumnData(q, 0) != null) 
		{
			local pos = ConvertPosToString(GetSQLColumnData(q, 2));
			HideMapObject(GetSQLColumnData(q, 1).tointeger(), pos.x, pos.y, pos.z);
			print(pos.x.tofloat() + " - " + pos.y.tofloat() + " - " + pos.z.tofloat())
			i++;
			::GetSQLNextRow(q);
		}
		::FreeSQLQuery(q);
	}
	print("[INF]  - " + i);
	Count = i;
}

function ConvertPosToString(vector)
{
	local result = split(vector, ",");
	return Vector(result[0].tofloat(), result[1].tofloat(), result[2].tofloat());
}
