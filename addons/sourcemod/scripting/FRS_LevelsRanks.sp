#pragma semicolon 1
#pragma newdecls required

#include <sdktools>
#include <lvl_ranks>
#include <FakeRank_Sync>

public Plugin myinfo = 
{
	name		= "[FRS][LR] LevelRanks FakeRank",
	version		= "2.0",
	description	= "Fake Ranks from your level in LR",
	author		= "ღ λŌK0ЌЭŦ ღ ™",
	url			= "https://github.com/IL0co"
}

#define IND "LR"

int cType;
KeyValues kv;

public void OnPluginEnd()
{
	FRS_UnRegisterMe();
}

public void OnPluginStart()
{
	LoadMyConfig();

	if(LR_IsLoaded())
		LR_OnCoreIsReady();
		
	for(int i = 1; i <= MaxClients; i++) 	if(IsClientAuthorized(i) && IsClientInGame(i))
		FRS_OnClientLoaded(i);

	FRS_OnCoreLoaded();
}

public void FRS_OnCoreLoaded()
{
	FRS_RegisterKey(IND);
}

public void LR_OnCoreIsReady()
{
	LR_Hook(LR_OnSettingsModuleUpdate, ConfigLoad);
	LR_Hook(LR_OnLevelChangedPost, OnClientLevelChanged);
}

public void OnMapStart()
{
	char Path[256];

	if(kv.GotoFirstSubKey(false))
	{
		do
		{
			FormatEx(Path, sizeof(Path), "materials/panorama/images/icons/skillgroups/skillgroup%i.svg", kv.GetNum(NULL_STRING, 0));
			if(FileExists(Path))	AddFileToDownloadsTable(Path);
		}
		while(kv.GotoNextKey(false));
	}

	kv.Rewind();
	kv.JumpToKey("FakeRank");
}

public void FRS_OnClientLoaded(int client)
{
	LoadMyIdFromLevel(client);
}

void OnClientLevelChanged(int client, int iNewLevel, int iOldLevel)
{
	LoadMyIdFromLevel(client);
}

void ConfigLoad()
{
	LoadMyConfig();
}

stock void LoadMyIdFromLevel(int client)
{
	char buff[5];
	Format(buff, sizeof(buff), "%i", LR_GetClientInfo(client, ST_RANK));
	FRS_SetClientRankId(client, kv.GetNum(buff, 0) + cType, IND);
}

stock void LoadMyConfig()
{
	char buff[256];
	BuildPath(Path_SM, buff, sizeof(buff), "configs/levels_ranks/fakerank.ini");	

	kv = new KeyValues("LR_FakeRank");

	if(!kv.ImportFromFile(buff))
		SetFailState("[FRS][LR] LevelsRanks File is not found (%s)", buff);

	cType = kv.GetNum("Type", 0);
	kv.JumpToKey("FakeRank");
}