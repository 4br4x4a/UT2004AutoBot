// AutoPlayMutator: toggle autopilot for YOUR character in offline games.
// Bind a key:  set Input F8 mutate AutoPlay
class AutoPlayMutator extends Mutator;

var PlayerController SavedPC;
var AutoBotController Brain;

function Mutate(string MutateString, PlayerController Sender)
{
    if (MutateString ~= "AutoPlay")
        Toggle(Sender);
    Super.Mutate(MutateString, Sender);
}

function Toggle(PlayerController PC)
{
    if (Level.NetMode != NM_Standalone)
    {
        PC.ClientMessage("AutoPlay is only available in standalone (offline) games.");
        return;
    }
    if (Brain == None)
        Enable(PC);
    else
        Disable();
}

function Enable(PlayerController PC)
{
    local Pawn P;

    P = PC.Pawn;
    if (P == None)
        return;

    SavedPC = PC;
    Brain = Spawn(class'AutoBotController');
    if (Brain == None)
        return;

    PC.UnPossess();
    Brain.Possess(P);
    PC.SetViewTarget(P);            // keep watching your own pawn
    PC.ClientMessage("AutoPlay ON");
    SetTimer(0.5, true);            // watch for death
}

function Disable()
{
    local Pawn P;

    SetTimer(0, false);
    if (Brain != None)
    {
        P = Brain.Pawn;
        Brain.UnPossess();
        Brain.Destroy();
        Brain = None;
    }
    if (SavedPC != None)
    {
        if (P != None)
            SavedPC.Possess(P);
        SavedPC.SetViewTarget(SavedPC);
        SavedPC.ClientMessage("AutoPlay OFF");
    }
}

function Timer()
{
    // pawn died: return control to the human so normal respawn works
    if (Brain != None && Brain.Pawn == None)
        Disable();
}

defaultproperties
{
    FriendlyName="AutoPlay"
    Description="Press the bound key to let a bot brain play your character (offline only)."
    GroupName="AutoBot"
}
