class MyBlade extends MyWeapon;

var() const name BladeHiltSocketName;
var() const name BladeTipSocketName;
var MyAttackProperties AttackAnim;


var array<Actor> SwingHitActors;
var array<int> Swings;
var const int MaxSwings;

reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
    local MyPawn MPawn;

    super.ClientGivenTo(NewOwner, bDoNotActivate);

    MPawn = MyPawn(NewOwner);

    if (MPawn != none && MPawn.Mesh.GetSocketByName(MPawn.SwordHandSocket) != none)
    {
        Mesh.SetShadowParent(MPawn.Mesh);
        Mesh.SetLightEnvironment(MPawn.LightEnvironment);
        MPawn.Mesh.AttachComponentToSocket(Mesh, MPawn.SwordHandSocket);
   }
}

function RestoreAmmo(int Amount, optional byte FireModeNum)
{
	Swings[FireModeNum] = Min(Amount, MaxSwings);

}

function ConsumeAmmo(byte FireModeNum)
{
	if(HasAmmo(FireModeNum))
	{
		Swings[FireModeNum]--;

	}

}

simulated function bool HasAmmo(byte FireModeNum, optional int Ammount)
{
	return Swings[FireModeNum] > Ammount;

}

simulated function FireAmmunition()
{
	//AgentCombat
   StopFire(CurrentFireMode);
   SwingHitActors.Remove(0, SwingHitActors.Length);

   if (HasAmmo(CurrentFireMode))
   {
		if(MaxSwings -Swings[0] == 0){
		MyPawn(Owner).AttackNode.PlayCustomAnim(AttackAnim.SwordAttack01Name, 1.0);
		}
      super.FireAmmunition();
	  `Log("==================Fire Ammunation");
   }
}

simulated state Swinging extends WeaponFiring
{
	simulated event Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);
		TraceSwing();
	}

	simulated event EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		SetTimer(GetFireInterval(CurrentFireMode), false, nameOf(ResetSwings));
	}

}

function ResetSwings()
{
	RestoreAmmo(MaxSwings);
}


function Vector GetSwordSocketLocation(name SocketName)
{
	local Vector SocketLocation;
	local Rotator SwordRotation;
	local SkeletalMeshComponent SMC;

	SMC =  SkeletalMeshComponent(Mesh);

	if(SMC != none && SMC.GetSocketByName(SocketName) != none)
	{
		SMC.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SwordRotation);
	}

	return SocketLocation;
}

function bool AddToSwingHitActors(Actor HitActor)
{
	local int i;

	for(i = 0; i < SwingHitActors.Length; i++)
	{
		if (SwingHitActors[i] == HitActor)
      {
         return false;
      }
	
	}

	SwingHitActors.AddItem(HitActor);
	return true;
}

function TraceSwing()
{

   local Actor HitActor;
   local Vector HitLoc, HitNorm, SwordTip, SwordHilt, Momentum;
   local int DamageAmount;

   SwordTip = GetSwordSocketLocation(BladeTipSocketName);
   SwordHilt = GetSwordSocketLocation(BladeHiltSocketName);
   DamageAmount = FCeil(InstantHitDamage[CurrentFireMode]);

   foreach TraceActors(class'Actor', HitActor, HitLoc, HitNorm, SwordTip, SwordHilt)
   {
      if (HitActor != self && AddToSwingHitActors(HitActor))
      {
         Momentum = Normal(SwordTip - SwordHilt) * InstantHitMomentum[CurrentFireMode];
         HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, class'DamageType');
		 

      }
   }
}




DefaultProperties
{
		//Archetype for Attack Animation
	AttackAnim=MyAttackProperties'Melee_Test.AnimArch.AnimAttack'

	MaxSwings=2
	Swings(0)=2

	bMeleeWeapon=true
	bInstantHit=true
	bCanThrow=false

	FiringStatesArray(0)="Swinging"
	WeaponFireTypes(0)=EWFT_Custom


	begin object class=SkeletalMeshComponent Name=SwordSkeletalComponent
		bCacheAnimSequenceNodes=false
       AlwaysLoadOnClient=true
       AlwaysLoadOnServer=true
       CastShadow=true
       BlockRigidBody=true
       bUpdateSkelWhenNotRendered=false
       bIgnoreControllersWhenNotRendered=true
       bUpdateKinematicBonesFromAnimation=true
       bCastDynamicShadow=true
       RBChannel=RBCC_Untitled3
       RBCollideWithChannels=(Untitled3=true)
       bOverrideAttachmentOwnerVisibility=true
       bAcceptsDynamicDecals=false
       bHasPhysicsAssetInstance=true
       TickGroup=TG_PreAsyncWork
       MinDistFactorForKinematicUpdate=0.2f
       bChartDistanceFactor=true
       RBDominanceGroup=20
       Scale=1.f
       bAllowAmbientOcclusion=false
       bUseOnePassLightingOnTranslucency=true
       bPerBoneMotionBlur=true
	end object

	Mesh=SwordSkeletalComponent
	//Components.Add(SwordSkeletalComponent)

}
