class MyPawn extends UDKPawn;

var AnimNodePlayCustomAnim AttackNode;
var AnimNodePlayCustomAnim PushNode;
var AnimNodePlayCustomAnim FallNode;


var float CamOffsetDistance; //distance to offset the camera from the player in unreal units
var float CamMinDistance, CamMaxDistance;
var float CamZoomTick; //how far to zoom in/out per command
var float CamHeight; //how high cam is relative to pawn pelvis

var()const Name SwordHandSocket;
var()const DynamicLightEnvironmentComponent LightEnvironment;




//Avoid aim node from aiming up and down
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{   
	super.PostInitAnimTree(SkelComp);
	AimNode.bForceAimDir = true; //forces centercenter
	AttackNode = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('AttackNode'));
	PushNode = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('PushNode'));
	FallNode = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('FallNode'));
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`log("I'm a pawn");
	
}

simulated event Destroyed()
{
	AttackNode = none;
	PushNode = none;
	FallNode = none;
}

function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

}

exec function CamZoomIn()
{
	`Log("Zoom in");
	if(CamOffsetDistance > CamMinDistance)
		CamOffsetDistance-=CamZoomTick;
}

exec function CamZoomOut()
{
	`Log("Zoom out");
	if(CamOffsetDistance < CamMaxDistance)
		CamOffsetDistance+=CamZoomTick;
}

/*
simulated function StartFire(byte FireModeNum)
{
  if (AttackNode == None)
  {
    return;
  }

	if (!AttackNode.bIsPlayingCustomAnim)
	{
		AttackNode.PlayCustomAnim(AttackAnim.SwordAttack01Name, 1.f, 0.1f, 0.1f, false, true);
		`Log("==================StarFire");

		//GroundSpeed = 0;
	}
}
*/

//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //set player controller to behind view and make mesh visible
         UTPC.SetBehindView(true);
         //SetMeshVisibility(UTPC.bBehindView); 
         UTPC.bNoCrosshair = true;
      }
   }
}

//only update pawn rotation while moving
simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
	// Do not update Pawn's rotation if no accel
	if (Normal(Acceleration)!=vect(0,0,0))
	{
		if ( Physics == PHYS_Ladder )
		{
			NewRotation = OnLadder.Walldir;
		}
		else if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
		{
			NewRotation = rotator((Location + Normal(Acceleration))-Location);
			NewRotation.Pitch = 0;
		}
		
		SetRotation(NewRotation);
	}
}


//orbit cam, follows player controller rotation
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector HitLoc,HitNorm, End, Start, vecCamHeight;

	vecCamHeight = vect(0,0,0);
	vecCamHeight.Z = CamHeight;
	Start = Location;
	End = (Location+vecCamHeight)-(Vector(Controller.Rotation) * CamOffsetDistance);  //cam follow behind player controller
	out_CamLoc = End;

	//trace to check if cam running into wall/floor
	if(Trace(HitLoc,HitNorm,End,Start,false,vect(12,12,12))!=none)
	{
		out_CamLoc = HitLoc + vecCamHeight;
	}
	
	//camera will look slightly above player
   out_CamRot=rotator((Location + vecCamHeight) - out_CamLoc);
   return true;
}


DefaultProperties
{

	

	//InventoryClass
	InventoryManagerClass=class 'MyInventoryManager'

	//Ligthing Environment
	//Skeletal Mesh and Initialize

	begin object class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=true
		 bSynthesizeSHLight=true
       bIsCharacterLightEnvironment=true

	end object  
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	begin object class=SkeletalMeshComponent Name=InitialSkeletalMesh

		LightEnvironment=MyLightEnvironment
		CastShadow=true
		BlockRigidBody=true

		//Add skeletal mesh
		//Add animset
		//Add anim tree
		//Add PhysicalAssets 
		SkeletalMesh=SkeletalMesh'Melee_Test.Mesh.AgentDefault'
		Animsets(0)=AnimSet'Melee_Test.Anim.AgentDefault_Anims'
		AnimTreeTemplate=AnimTree'Melee_Test.Anim.AgentAnimTree'
		PhysicsAsset=PhysicsAsset'Melee_Test.Mesh.AgentDefault_Physics'
		

	end object
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh)

	CamHeight = 40.0
	CamMinDistance = 40.0
	CamMaxDistance = 350.0
   	CamOffsetDistance=250.0
	CamZoomTick=20.0

	CollisionType=COLLIDE_BlockAll

	begin object  Name=CollisionCylinder
		CollisionRadius=+035
		CollisionHeight=+039
	end object
	CylinderComponent=CollisionCylinder


}
