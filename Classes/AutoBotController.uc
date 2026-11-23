// AutoBotController: custom bot brain. Utility-scored states instead of stat tweaks.
// Offline use only: refuses to run unless the game is standalone.
class AutoBotController extends XBot config(AutoBot);

var config float RetreatHealth;     // below this, prefer Retreat
var config float WeightFight;
var config float WeightGrabItem;
var config float WeightRoam;
var config float WeightRetreat;
var config float ThinkInterval;

var name BrainState;                // Fight / Roam / GrabItem / Retreat (for logging)

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if (Level.NetMode != NM_Standalone)
    {
        Log("AutoBotController: refusing to run outside standalone games.");
        Destroy();
        return;
    }
    SetTimer(ThinkInterval, true);
}

function float ScoreFight()
{
    if (Enemy == None || Pawn == None)
        return 0;
    return WeightFight * (float(Pawn.Health) / 100.0)
         * FClamp(1.0 - VSize(Enemy.Location - Pawn.Location) / 3000.0, 0.1, 1.0);
}

function float ScoreRetreat()
{
    if (Enemy == None || Pawn == None || Pawn.Health >= RetreatHealth)
        return 0;
    return WeightRetreat * (1.0 - float(Pawn.Health) / RetreatHealth);
}

function float ScoreGrabItem()
{
    if (Pawn == None)
        return 0;
    // more attractive when hurt or no enemy is in sight
    return WeightGrabItem * (1.0 - float(Pawn.Health) / 150.0) + ((Enemy == None) ? 0.3 : 0.0);
}

function PickRangeWeapon()
{
    local Weapon W;

    if (Pawn == None || Enemy == None)
        return;
    W = class'WeaponPrefs'.static.PickWeapon(Pawn, VSize(Enemy.Location - Pawn.Location));
    if (W == None)
        SwitchToBestWeapon();                       // fall back to stock choice
    else if (W != Pawn.Weapon)
    {
        Pawn.PendingWeapon = W;
        if (Pawn.Weapon != None)
            Pawn.Weapon.PutDown();
        else
            Pawn.ChangedWeapon();
    }
}

function Timer()
{
    local float f, r, g, w, best;

    Super.Timer();      // keep the stock bot's own timer logic running
    if (Pawn == None)
        return;

    f = ScoreFight();
    r = ScoreRetreat();
    g = ScoreGrabItem();
    w = WeightRoam * 0.2;

    best = FMax(FMax(f, r), FMax(g, w));
    if (best == r && r > 0)      BrainState = 'Retreat';
    else if (best == f && f > 0) BrainState = 'Fight';
    else if (best == g)          BrainState = 'GrabItem';
    else                         BrainState = 'Roam';

    switch (BrainState)
    {
        case 'Retreat':
            CombatStyle = -1.0;                 // hold distance, keep moving
            if (!IsInState('Hunting'))
                GotoState('Hunting');           // placeholder: stock logic with retreat bias
            break;
        case 'Fight':
            CombatStyle = 0.6;
            PickRangeWeapon();
            break;
        case 'GrabItem':
        case 'Roam':
            CombatStyle = 0.0;
            if (Enemy == None)
                WhatToDoNext(12);               // stock logic picks pickups / roam targets
            break;
    }
}

defaultproperties
{
    RetreatHealth=40
    WeightFight=1.0
    WeightGrabItem=0.8
    WeightRoam=0.5
    WeightRetreat=1.5
    ThinkInterval=0.5
}
