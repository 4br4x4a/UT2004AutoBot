// WeaponPrefs: per-range weapon priority lists (stock UT2004 weapon class names).
class WeaponPrefs extends Object;

// Returns a '|'-separated priority list for the given distance (UU).
static function string ListForRange(float Dist)
{
    if (Dist < 700)    // close: flak, shock combo, assault
        return "XWeapons.FlakCannon|XWeapons.ShockRifle|XWeapons.BioRifle|XWeapons.AssaultRifle";
    if (Dist < 2200)   // mid: shock, rockets, link
        return "XWeapons.ShockRifle|XWeapons.RocketLauncher|XWeapons.LinkGun|XWeapons.FlakCannon";
    // far: lightning, shock, minigun
    return "UTClassic.ClassicSniperRifle|XWeapons.SniperRifle|XWeapons.ShockRifle|XWeapons.Minigun";
}

// Finds the first weapon in P's inventory that matches the range list and has ammo.
static function Weapon PickWeapon(Pawn P, float Dist)
{
    local array<string> Names;
    local Inventory Inv;
    local int i;

    Split(ListForRange(Dist), "|", Names);
    for (i = 0; i < Names.Length; i++)
    {
        for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            if (Weapon(Inv) != None && string(Inv.Class) ~= Names[i] && Weapon(Inv).HasAmmo())
                return Weapon(Inv);
        }
    }
    return None;
}

defaultproperties
{
}
