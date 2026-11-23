// AutoBotSwapMutator: gives every botmatch bot the AutoBotController brain.
// Fallback approach: after a bot spawns, replace its controller and keep its PRI.
// (Cleaner approach, to verify in game source: set the bot controller class before spawn.)
class AutoBotSwapMutator extends Mutator;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if (Level.NetMode != NM_Standalone)
        return;
    SetTimer(1.0, true);
}

function Timer()
{
    local Controller C;
    local Bot B;
    local AutoBotController Brain;
    local Pawn P;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        B = Bot(C);
        if (B == None || AutoBotController(C) != None || B.Pawn == None)
            continue;

        P = B.Pawn;
        Brain = Spawn(class'AutoBotController');
        if (Brain == None)
            continue;

        Brain.PlayerReplicationInfo = B.PlayerReplicationInfo;   // keep name/score/team
        B.PlayerReplicationInfo = None;
        B.UnPossess();
        Brain.Possess(P);
        B.Destroy();
        return;     // one swap per tick keeps the ControllerList iteration safe
    }
}

defaultproperties
{
    FriendlyName="AutoBot Brain"
    Description="Replaces stock bot brains with AutoBotController (offline only)."
    GroupName="AutoBot"
}
