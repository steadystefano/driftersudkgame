class MyGameInfo extends UDKGame;

var() const  MyPawn PawnArchetype;
var() const MyBlade BladeArchetype;



event PostBeginPlay()
{
	`log("Im a gameinfo");

}

event AddDefaultInventory(Pawn P)
{
    local MyInventoryManager MInventoryManager;

    super.AddDefaultInventory(P);

    if (BladeArchetype != None)
    {
        MInventoryManager = MyInventoryManager(P.InvManager);

        if (MInventoryManager != None)
        {
            MInventoryManager.CreateInventoryArchetype(BladeArchetype, false);
        }
    }
}

function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
    local Pawn SpawnedPawn;

    if (NewPlayer == none || StartSpot == none)
    {
        return none;
    }

    SpawnedPawn = Spawn(PawnArchetype.Class,,, StartSpot.Location,, PawnArchetype);

    return SpawnedPawn;
}

DefaultProperties
{
	PlayerControllerClass=class'MyPlayerController'
	//DefaultPawnClass=class'MyPawn'
	PawnArchetype=MyPawn'Melee_Test.Pawn.Pawn'
	BladeArchetype=MyBlade'Melee_Test.WeapArch.WeaponArchetype'

	bDelayedStart=false

}
