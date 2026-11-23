// AutoBotMutator: tunes every Bot in the match (aggression, strafing, accuracy,
// weapon pick, item hunting). Offline / local botmatch use.
class AutoBotMutator extends Mutator config(AutoBot);

var config float BotSkill;          // 0..7
var config float Aggression;        // 0..1 (CombatStyle)
var config float StrafeAbility;     // -1..1
var config float AccuracyBonus;     // -1..1
var config float TuneInterval;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(TuneInterval, true);
}

function Timer()
{
    local Controller C;
    local Bot B;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        B = Bot(C);
        if (B == None || B.Pawn == None)
            continue;

        B.Skill          = FClamp(BotSkill, 0, 7);
        B.Accuracy       = AccuracyBonus;
        B.StrafingAbility= StrafeAbility;
        B.CombatStyle    = Aggression;     // >0 charges, <0 holds distance
        B.bJumpy         = true;           // dodge more
        B.bLeadTarget    = true;           // lead projectiles

        // always prefer the best weapon for current range
        B.Pawn.Controller.SwitchToBestWeapon();
    }
}

defaultproperties
{
    FriendlyName="AutoBot"
    Description="Makes bots play more aggressively and accurately."
    GroupName="AutoBot"
    BotSkill=6.0
    Aggression=0.6
    StrafeAbility=0.8
    AccuracyBonus=0.5
    TuneInterval=1.0
}
