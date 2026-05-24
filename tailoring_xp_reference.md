# Tailoring XP Reference (B42)

All data extracted from `media/scripts/generated/recipes/recipes_tailoring*.txt` and `recipes_sacks.txt` in the Project Zomboid install. Action XP for non-crafting actions from `media/lua/shared/TimedActions/`.

---

## Quick reference

**XP per level (cumulative, approximate B41/B42 Crafting curve — verify in your save):**

| Level reached | XP to reach this level | Cumulative |
|---|---|---|
| 1 | 75 | 75 |
| 2 | 150 | 225 |
| 3 | 300 | 525 |
| 4 | 750 | 1,275 |
| 5 | 1,500 | 2,775 |
| 6 | 3,000 | 5,775 |
| 7 | 4,500 | 10,275 |
| 8 | 6,000 | 16,275 |
| 9 | 7,500 | 23,775 |
| 10 | 9,000 | 32,775 |

**Skill book / magazine XP multipliers** (from `XPSystem_SkillBook.lua`):

| Book tier | Multiplier | Caps at level |
|---|---|---|
| Tailoring Vol. 1 | ×3 | 2 |
| Tailoring Vol. 2 | ×5 | 4 |
| Tailoring Vol. 3 | ×8 | 6 |
| Tailoring Vol. 4 | ×12 | 8 |
| Tailoring Vol. 5 | ×16 | 10 |

A read book is worth a *huge* multiplier even if you're grinding the same recipes — read everything you find before grinding.

**Standard trait modifiers:**
- Tailor: starts at Tailoring 1, +2 boost (read books at 2× speed too)
- Fast Learner: ×1.3 XP gain
- Slow Learner: ×0.7 XP gain

**Other XP sources (from Lua, not recipe scripts):**
- Rip Clothing into rags: ~1 XP per piece returned (varies; nerfed from B41)
- Sew patch onto clothing: 2 XP per patch (`ISRepairClothing.lua:74`)
- Remove patch from clothing: 2 XP per removal (`ISRemovePatch.lua:52`)
- Patch action time: `150 − (level × 6)` ticks — gets faster with skill

---

## The only closed-loop XP recipes

These two pairs let you craft → un-craft → re-craft indefinitely, losing only thread per cycle:

| Loop | Skill | Cost/cycle | XP/cycle | Total time/cycle |
|---|---|---|---|---|
| `SewSack` ↔ `ScrapSack` | 0 | 1 Thread | 8 | 400 |
| `SewSackGunny` ↔ `ScrapSackLarge` | 1 | 1 Thread | 9 | 400 |

Scrap recipes themselves give 0 XP. Thread is recovered via `PickThread` (level 1, 200 time, 0 XP) from any RippedSheets/DenimStrips — clothing → rags is unlimited.

Loops that work materially but give **no XP** (don't bother for grinding): `MakeSheetSlingBag`/`UnmakeSheetSlingBag`, `TieRopeBelt`/`UntieRopeBelt`, `TieHeadband`/`UntieHeadband`, `MakeTarpSlingBag` (also burns duct tape).

---

## Recipe table — sorted by skill required

### Level 0 (no skill required)

| Recipe | XP | Time | Inputs (consumed) | Output | Notes |
|---|---|---|---|---|---|
| SewRagBandana | 8 | **100** | 2 RippedSheets, 1 Thread/Twine | Hat_RagBandana | Best XP/time at lvl 0 |
| SewHeadwrap | 8 | 200 | 5 RippedSheets (or 2 BurlapPiece) + 2 Thread | Shemagh hat | |
| SewHandwrap | 8 | 200 | 6 Strips (any) + 2 Thread | Wrap gloves | |
| SewFootwrap | 8 | 200 | 6 Strips (any) + 1 Thread | Wrap shoes | |
| SewImprovisedBandeau | 8 | 200 | 4 Strips + 2 Thread | Bandeau | |
| SewSack | 8 | 200 | 1 BurlapPiece + 1 Thread | EmptySandbag | **Half of sack loop** |
| ScrapSack | 0 | 200 | 1 burlapbag-tagged | 1 BurlapPiece | **No XP, recovery half** |
| ScrapSackLarge | 0 | 200 | 1 largesack-tagged | 2 BurlapPiece | **No XP, recovery half** |
| CutSheet | 0 | 60 | 1 FabricRoll_Cotton | 1 Sheet | No XP |
| ConvertIntoFingerlessGloves | 0 | 60 | 1 Leather gloves | Fingerless gloves | No XP |
| MakeSheetSlingBag / Unmake | 0 | 50 | 1 Sheet ↔ Bag_SheetSlingBag | | No XP, material-neutral |
| TieRopeBelt / Untie | 0 | 50 | 1 Rope ↔ RopeBelt | | No XP |
| TieHeadband / Untie | 0 | 50 | 1 LeatherStrips ↔ Hat | | No XP |
| ShortenSkirt / Sleeves / Socks / Trousers | 0 | 60 | Long version → short | + RippedSheets/DenimStrips | No XP, one-shot per item |
| DyeClothes | 0 | 150 | Bucket + Water + Dye + item | Dyed item | No XP |
| MakeGarbageBagApron / Skirt / Bandeau / Briefs / TankTop / HeadSack / KneeSkirt / LongSkirt / ShortSkirt / Dress | 6 | 100–200 | 1–2 GarbageBag + 1–3 DuctTape | Garbage clothes | DuctTape consumed each time |
| TarpHat / TarpHandwrap / TarpFootwrap / TarpSack / TarpDress / TarpSkirt etc. | 6 | 200 | 1–4 TarpPiece + 1–3 DuctTape (+ thread on Sack) | Tarp clothes | DuctTape consumed |
| MakeGarbageBagHeadSack | 6 | 100 | 1 GarbageBag + 1 DuctTape | Hood | |
| CutHeadSack | 0 | 100 | 1 sack/pillow + scissors | HeadSack hat | No XP |

### Level 1

| Recipe | XP | Time | Inputs (consumed) | Output | Auto-learn | Notes |
|---|---|---|---|---|---|---|
| **SewSackGunny** | **9** | 200 | 2 BurlapPiece + 1 Thread | Bag_Gunny | n/a | **Best loop half** — pairs with ScrapSackLarge |
| SewHeadSack | 9 | 200 | 1 Burlap/Cotton/Sheet + 1 Thread | Headsack hat | n/a | |
| SewDressKnees | 9 | 200 | 1 Fabric + 1 Thread | Crafted dress | 3 | NeedToBeLearn |
| SewDressLong | 9 | 200 | 1 Fabric + 1 Thread | Long crafted dress | 3 | NeedToBeLearn |
| SewSkirtKnees | 9 | 200 | 2 Fabric + 2 Thread | Crafted skirt | 3 | NeedToBeLearn |
| SewSkirtLong | 9 | 200 | 3 Fabric + 3 Thread | Long crafted skirt | 3 | NeedToBeLearn |
| SewShirtSleeveless | 9 | 200 | 2 Fabric + 2 Thread + 3 Buttons | Sleeveless shirt | 3 | NeedToBeLearn |
| SewImprovisedBriefs | 9 | 200 | 4 Strips + 1 Thread | Briefs | n/a | |
| SewPillow | 9 | 200 | 1 FabricRoll + 1 Thread + 100 Feathers/10 CottonBalls/5 WoolRaw | Pillow_Crafted | n/a | |
| DivideShoulderpads | 9 | 180 | 1 football shoulderpads + 4 LeatherStrips + 2 HeavyThread | 2 separate pads | n/a | One-shot per pads |
| SewNeckguard | 9 | 200 | 6 Strips + 2 Thread | Gorget | n/a | |
| MakeDuctTapeHolster | 9 | 100 | 3 DuctTape + 1 pistol (kept) | Holster_DuctTape | n/a | Pistol returned |
| MakeGarbageBagPoncho / MakeTarpPoncho | 9 | 200 | 2 GarbageBag or 1 Tarp + 3 DuctTape | Poncho | n/a | |
| WeaveTwineShoes | 9 | 200 | 5 Twine | Shoes_Twine | 4 | NeedToBeLearn |
| MakeBodyMagazineArmor | 0 | 100 | 8 magazines + 4 DuctTape | Cuirass_Magazine | n/a | NeedToBeLearn, no XP! |
| MakeForearmMagazineArmor | 0 | 100 | 1 magazine + 2 DuctTape | VambraceMagazine | n/a | No XP |
| SewHideBandeau | 11 | 200 | 1 small hide + 1 Thread | Hide bandeau | n/a | |
| SewHideSack | 11 | 200 | 1 medium hide + 1 Thread | Bag_HideSack | n/a | |
| SewHideSlingBag | 11 | 200 | 1 medium hide + 1 HeavyThread + 1 LeatherStrips | Bag_HideSlingBag | n/a | |
| SewPouch | 11 | 200 | 1 small hide + 1 Thread | SeedBag | n/a | |
| SewCrudeLeatherShoes | 11 | 200 | 1 small hide + 1 HeavyThread | Crude leather shoes | n/a | |
| MakeWoodForearmArmor | 11 | 180 | 4 WoodenStick2 + 2 LeatherStrips + 1 Twine | VambraceWood | 5 | NeedToBeLearn, also +20 Carving |
| MakeWoodShinArmor | 11 | 180 | same as forearm | GreaveWood | 5 | NeedToBeLearn |
| MakeWoodThighArmor | 11 | 180 | same | ThighWood | 5 | NeedToBeLearn |
| MakeTireSandals | 9 | 180 | 1 TirePiece + 2 LeatherStrips + 2 Buckle + 1 Thread | TireSandals | 3 | NeedToBeLearn, also +10 Maintenance |
| PickThread | 0 | 200 | 1 RippedSheets/DenimStrips | 1 Thread | n/a | **No XP** but enables sack loop |

### Level 2

| Recipe | XP | Time | Inputs (consumed) | Output | Auto-learn | Notes |
|---|---|---|---|---|---|---|
| **SewBelt** | **16** | 200 | 2 LeatherStrips + 1 HeavyThread + 1 Buckle | Belt2 | 4 | NeedToBeLearn |
| SewSandals | 16 | 200 | 1 small hide + 1 HeavyThread + 2 LeatherStrips + 2 Buckle | Sandals | 4 | NeedToBeLearn |
| SewLeatherGaiter | 16 | 200 | 1 small hide + 1 HeavyThread + 1 LeatherStrips + 2 Buckle | Gaiter | 5 | NeedToBeLearn, **batch craft allowed** |
| SewLeatherToolRoll | 16 | 200 | 1 medium hide + 1 LeatherStrips + 1 HeavyThread + 1 Buckle | ToolRoll | — | NeedToBeLearn, no auto-learn |
| SewCrudeTarpBackpack | 16 | 200 | 3 TarpPiece + 2 Thread + 3 DuctTape + 2 strips/rope/tape | Bag_CrudeTarpBag | 5 | NeedToBeLearn |
| MakeMattress | 13 | 180 | 5 Thread + 5 Sheet + 5 pillow | Mattress | n/a | |
| SewShirt | 13 | 200 | 3 Fabric + 3 Thread + 3 Buttons | Crafted shirt | 4 | NeedToBeLearn |
| SewClothSatchel | 13 | 200 | 2 Fabric + 2 Thread | Bag_ClothSatchel | 3 | NeedToBeLearn |
| KnitSocks / KnitLegwarmers / KnitWoolyHat | 13 | 200 | 1 Yarn | Socks/Legwarmers/Hat | — | Research only (no auto-learn) |
| SewHideHeadSack | 13 | 200 | 1 small hide + 1 Thread | Hide headsack | n/a | |
| SewHideSkirtKnees / Skirt / SkirtLong / SkirtShort | 13 | 200 | 1 medium or large hide + 1 Thread | Hide skirts | n/a | |
| SewHideDress | 13 | 200 | 1 medium hide + 4 HeavyThread | Hide dress | n/a | |
| SewHideHat | 13 | 200 | 1 small hide + 1 Thread | Hide hat | — | NeedToBeLearn, no auto-learn |
| SewLeatherVambrace | 13 | 200 | 1 small hide + 1 HeavyThread + 1 LeatherStrips | Vambrace_Leather | — | NeedToBeLearn |
| MakeBoneMask | 13 | 180 | 6 SmallAnimalBone + 1 LeatherStrips + 1 Twine | BoneMask | n/a | +20 Carving |
| MakeBonePectoral | 13 | 180 | 6 SmallAnimalBone + 2 LeatherStrips + 1 Twine | Cuirass_BasicBone | n/a | +20 Carving |

### Level 3

| Recipe | XP | Time | Inputs (consumed) | Output | Auto-learn | Notes |
|---|---|---|---|---|---|---|
| **SewTrousers** | **20** | 200 | 3 Fabric + 3 Thread | Crafted trousers | 5 | NeedToBeLearn, **best XP/time** at this tier |
| KnitBalaclavaFace / KnitSweaterVest | 20 | 200 | 1 Yarn | Balaclava/Vest | — | Research only |
| SewHideBra / BraStrapless | 20 | 200 | 1 small hide + 1 Thread | Hide bra | n/a | |
| SewHideBriefs / SewHideUnderpants | 20 | 200 | 1 small hide + 1 Thread | Hide briefs/underpants | n/a | |
| SewHideTankTop | 20 | 200 | 1 small leather-fur + 2 Thread | Hide vest | n/a | |
| SewHideSatchel | 20 | 200 | 1 medium hide + 2 HeavyThread + 1 LeatherStrips | Bag_HideSatchel | n/a | |
| SewHideWallet | 20 | 200 | 1 small hide + 1 HeavyThread | Wallet | — | NeedToBeLearn |
| SewHideApron / SewLeatherApron | 20 | 200 | 1 large hide + 2 LeatherStrips + 3 HeavyThread | Hide/Leather apron | n/a / n/a | LeatherApron not learned, HideApron is |
| SewHideMask | 20 | 200 | 1 small hide + 1 HeavyThread + 1 LeatherStrips | Hockey mask hide | — | NeedToBeLearn |
| SewHidePants | 20 | 200 | 1 medium hide + 3 HeavyThread | Hide trousers | — | NeedToBeLearn |
| SewHidePants2 | 25 | 200 | 2 small hides + 3 HeavyThread | Hide trousers (alt) | — | NeedToBeLearn |
| SewHideRobe | 20 | 200 | 1 large hide + 3 HeavyThread | Long coat hide | — | NeedToBeLearn |
| SewHideSleepingBag | 20 | 200 | 2 large hides + 10 WoolRaw + 2 SheepLeather + 8 HeavyThread | Sleeping bag | — | NeedToBeLearn, expensive |
| SewLeatherCodpiece | 25 | 200 | 1 small hide + 1 HeavyThread + 1 LeatherStrips | Codpiece | — | NeedToBeLearn |
| SewLeatherGorget | 25 | 200 | 1 small hide + 1 HeavyThread + 1 Buckle | Gorget_Leather | — | NeedToBeLearn |
| MakeTireForearmArmor / MakeTireShinArmor / MakeTireThighArmor | 20 | 180 | 1 TirePiece + 2 LeatherStrips + 2 Buckle + 2 NutsBolts + 1 HeavyThread | Tire armor | 5 | NeedToBeLearn, +20 Maintenance |
| SewTarpFannyBag | 20 | 200 | 1 TarpPiece + 1 Thread + 3 DuctTape | Fanny pack | — | NeedToBeLearn |

### Level 4

| Recipe | XP | Time | Inputs (consumed) | Output | Auto-learn | Notes |
|---|---|---|---|---|---|---|
| **SewBear** | **38** | 200 | 1 Fabric + 1 Thread + 2 Buttons + 100 Feathers / 10 CottonBalls / 5 WoolRaw | ToyBear | n/a | **Best XP/time** at this tier |
| **MakeTarpChestRig** | **38** | 200 | 3 TarpPiece + 6 DuctTape + 4 Thread | Bag_ChestRig_Tarp | — | NeedToBeLearn |
| SewHolster | 38 | 200 | 1 small hide + 1 HeavyThread + 1 Buckle + 1 LeatherStrips | Holster_Hide | — | NeedToBeLearn |
| SewKneePads / SewElbowPads | 38 | 200 | 1 medium hide + 2 HeavyThread (+ 2 strips + 2 buckle for knees) | Pad pair | — | NeedToBeLearn, **outputs L + R** |
| KnitBalaclavaFull | 30 | 200 | 1 Yarn | Balaclava full | — | Research only |
| SewHideFannyBag | 30 | 200 | 1 small hide + 1 HeavyThread + 1 LeatherStrips | Fanny pack hide | — | NeedToBeLearn |
| SewHideBoots | 30 | 200 | 1 medium hide + 1 HeavyThread | Hide boots | — | NeedToBeLearn |
| SewHideCoat | 30 | 200 | 1 large hide + 3 Buttons + 6 HeavyThread | Long hide coat | — | NeedToBeLearn |
| SewHideJacket | 30 | 200 | 1 medium hide + 3 Buttons + 4 HeavyThread | Hide jacket | — | NeedToBeLearn |
| SewSheepskinVest | 30 | 200 | 1 SheepLeather_Fur_Tan + 3 HeavyThread | Sheepskin vest | — | NeedToBeLearn |
| SewSheepskinPants | 30 | 200 | 1 SheepLeather_Fur_Tan + 3 HeavyThread | Sheepskin pants | — | NeedToBeLearn |
| SewFurHat | 30 | 200 | 1 small fur leather + 2 Thread | Raccoon/winter/cowboy hat | n/a | Auto-available |
| SewLongjohnsBottom | 30 | 200 | 3 Fabric + 3 Thread | Longjohns bottoms | 6 | NeedToBeLearn |
| MakeBoneChoker | 30 | 180 | 4 BoneBead_Large + 1 LeatherStrips + 1 Twine | Choker | — | NeedToBeLearn |
| MakeBoneForearmArmor / MakeBoneShinArmor / MakeBoneThighArmor | 30 | 180 | 3–5 bones + 2 LeatherStrips + 1 Twine | Bone armor | 6 | NeedToBeLearn, +50 Carving |
| MakeTireShoulderArmorLeft / Right | 30 | 180 | 1 TirePiece + 2 LeatherStrips + 1 Buckle + 2 NutsBolts + 1 HeavyThread | Tire shoulder | 5–6 | NeedToBeLearn, +30 Maintenance |
| MakeWoodShoulderArmor | 30 | 180 | 4 WoodenStick2 + 2 LeatherStrips + 1 Twine | Wood shoulder | 6 | NeedToBeLearn, +30 Carving |
| CarveWoodenMask | 0 | 400 | 1 Plank + 2 LeatherStrips | Hockey mask wood | n/a | Carving XP only (+40), no Tailoring XP |

### Level 5

| Recipe | XP | Time | Inputs (consumed) | Output | Auto-learn | Notes |
|---|---|---|---|---|---|---|
| **AssembleLargeTarpFramepack** | **55** | 200 | 1 Tarp + 4 Thread + 4 DuctTape + 3 strips/tape/rope + 5 WoodenStick2 | Tarp framepack | — | NeedToBeLearn |
| **AssembleLargeFramepack** | **55** | 200 | 1 large hide + 4 HeavyThread + 2 strips/rope + 3 strips/tape/rope + 5 WoodenStick2 | Crafted framepack | — | NeedToBeLearn |
| **SewBandolier / SewShellsBandolier** | **55** | **400** | 4 LeatherStrips + 4 HeavyThread + 1 Buckle | Ammo strap | — | NeedToBeLearn, slower |
| SewLongjohns | 45 | 200 | 5 Fabric + 5 Thread | Longjohns | 7 | NeedToBeLearn, **cleanest sustainable grind** |
| SewCrudeLeatherBackpack | 45 | 200 | 1 medium hide + 2 HeavyThread + 2 strips/rope | Bag_CrudeLeatherBag | — | NeedToBeLearn |
| SewHideHoodie | 45 | 200 | 1 large hide + 3 Buttons + 4 HeavyThread | Hide hoodie | — | NeedToBeLearn |
| SewFurredHideJacket | 45 | 200 | 2 fur leather + 3 Buttons + 4 HeavyThread | Fur jacket | — | NeedToBeLearn |
| MakeBoneArmoredGloves | 45 | 180 | 4 SmallAnimalBone + 1 fingerless gloves + 1 Twine | BoneGloves | 7 | NeedToBeLearn, +30 Carving |
| MakeBoneShoulderArmor | 45 | 180 | 5 SmallAnimalBone + 2 LeatherStrips + 1 Twine | Bone shoulder | 7 | NeedToBeLearn, +50 Carving |
| MakeWoodBodyArmor | 45 | 180 | 10 WoodenStick2 + 4 LeatherStrips + 5 Twine | Cuirass_Wood | 7 | NeedToBeLearn, +50 Carving |
| MakeForearm/Shin/ThighBulletproofVestArmor | 45 | **300** | 1 BulletVest + 2 DuctTape + 5 HeavyThread | Vest-limb armor pair | 7 | NeedToBeLearn, **outputs L + R** |
| SewHolsterDouble | 55 | 200 | 1 medium hide + 2 HeavyThread + 1 Buckle + 1 LeatherStrips | Double holster | — | NeedToBeLearn |
| SewLeatherWaterBag | 38 | 200 | 1 medium hide + 2 HeavyThread + 1 LeatherStrips | Water bag | 6 | NeedToBeLearn (auto at 6, but available at 4) |
| SpikePadding / SpikePaddingLarge | 45 | 300 | 1 padded armor + 1 small hide + 2 HeavyThread + 3 Nails | Spiked armor | 7 | NeedToBeLearn, +10 Maintenance |

### Level 6

| Recipe | XP | Time | Inputs (consumed) | Output | Auto-learn | Notes |
|---|---|---|---|---|---|---|
| **SewLeatherGloves** | **68** | 200 | 1 small hide + 2 HeavyThread | Leather gloves | — | NeedToBeLearn, **practical workhorse** |
| **SewFurredHideCoat** | **68** | 200 | 4 fur leather + 3 Buttons + 6 HeavyThread | Long fur coat | — | NeedToBeLearn |
| **MakeTireBodyArmor** | **68** | 180 | 2 TirePiece + 4 LeatherStrips + 4 NutsBolts + 1 HeavyThread | Cuirass_Tire | 8 | NeedToBeLearn, +50 Maintenance |
| **SewLeatherPants** | **68** | 200 | 1 medium hide + 3 HeavyThread | Crafted leather pants | — | NeedToBeLearn |
| AssembleAdvancedFramepack | 75 | 200 | 1 large hide + 4 HeavyThread + 6 LeatherStrips + 1 PackFrame | Advanced pack | — | NeedToBeLearn, **PackFrame rare** |

### Level 7+

| Recipe | XP | Time | Inputs (consumed) | Output | Auto-learn | Notes |
|---|---|---|---|---|---|---|
| **AssembleAdvancedLargeFramepack** | **90** | 200 | 2 large hides + 8 HeavyThread + 8 LeatherStrips + 1 PackFrameLarge | Large advanced pack | — | NeedToBeLearn lvl 7, PackFrameLarge rare |
| **MakeWesternBoots** | **80** + 20 Carving | 200 | 1 medium hide + 2 HeavyThread + 1 Plank | Cowboy boots | 9 | NeedToBeLearn lvl 7, +Carving |
| **MakeBoneBodyArmor** | **80** + 60 Carving | 180 | 20 BoneBead_Large + 4 LeatherStrips + 5 Twine | Cuirass_Bone | 9 | NeedToBeLearn lvl 7 |

---

## How to "learn" recipes without books

- **Auto-learn**: hit the level in the `Auto-learn` column and the recipe just appears.
- **Research action**: right-click an item that is the *output* of a recipe → Research. Costs in-game time scaled by recipe difficulty. Works in light only. Faster with Reading Glasses (×0.9) or a Magnifier in hand (×0.9), Fast Learner (×0.7), Slow Learner (×1.3).
- **Useful research targets from common loot:**
  - `Hat_Beany`, `Hat_WoolyHat`, `Hat_BalaclavaFace`, `Hat_BalaclavaFull`, `Scarf_White`, `Socks_Heavy`, `Socks_LegWarmers`, `Doily`, `Jumper_TankTopTINT` → unlocks all knitting recipes
  - `Hat_RagBandana`, `Hat_HeadSack_*` → trivial sewn recipes (already auto-available)
  - Crafted hide/leather goods (`Bag_HideSack`, `Apron_Leather`, etc.) — rarely findable as loot since they have "_Crafted" / "_Hide" suffixes

---

## XP-per-minute estimates (assuming ~200 ticks ≈ 20 real seconds, no buffs)

| Tier | Best recipe | XP/cycle | Time | XP/min (raw) | With Tailor V5 book ×16 |
|---|---|---|---|---|---|
| Lvl 0 | SewRagBandana | 8 | 100 | 48 | 768 |
| Lvl 1–2 | SewSackGunny loop | 9 | 400 | 13.5 | 67 (×5 cap at lvl 2) |
| Lvl 3 | SewTrousers | 20 | 200 | 60 | 480 (×8 cap at lvl 4) |
| Lvl 4 | SewBear | 38 | 200 | 114 | 912 |
| Lvl 5 | AssembleLargeTarpFramepack | 55 | 200 | 165 | 1980 (×12 cap at lvl 6) |
| Lvl 6 | SewLeatherGloves | 68 | 200 | 204 | 2448 |
| Lvl 7+ | AssembleAdvancedLargeFramepack | 90 | 200 | 270 | 4320 (×16 cap at lvl 8) |

*XP-per-minute is theoretical max excluding material gathering. The bottleneck past level 2 is **producing inputs** (especially hide and thread), not the craft action itself. Run the sack loop while your tanning rack works.*

---

## Min-mats per XP — absolute best recipe per level

| Level | Without knitting | With knitting (research a beanie!) |
|---|---|---|
| **0** | **SewSack loop** → 1 Thread / 8 XP | (no knit recipe at lvl 0) |
| **1** | **SewSackGunny loop** → 1 Thread / 9 XP | **KnitBeany** → 1 Yarn / 9 XP (no thread!) |
| **2** | SewSackGunny loop → 1 Thread / 9 XP | **KnitWoolyHat / KnitSocks / KnitLegwarmers** → 1 Yarn / 13 XP |
| **3** | SewSackGunny loop → 1 Thread / 9 XP | **KnitSweaterVest** or **KnitBalaclavaFace** → 1 Yarn / 20 XP |
| **4** | SewSackGunny loop → 1 Thread / 9 XP | **KnitBalaclavaFull** → 1 Yarn / 30 XP ← peak mat efficiency in the entire tree |
| **5–10** | SewSackGunny loop → 1 Thread / 9 XP | KnitBalaclavaFull stays best (no higher-level knit recipes exist) |

**The catch:** the sack loop is mat-optimal forever, but XP-per-craft is locked at 9. Past level 4 the XP curve roughly doubles per level — thousands of cycles to ding 7→8. The loop is min-mat always, min-time only through level 2.

**KnitBalaclavaFull is the true GOAT from level 4 on**: 30 XP per single Yarn, no thread, no scissors, no needle, no fabric — just yarn and knitting needles (kept tool). One sweater rips into 2+ Yarn = 60+ XP at any level.

### Practical hybrid (min-mat that finishes this decade)

| Level | Pick | Why |
|---|---|---|
| 0–1 | SewSack/Gunny loop | Truly closed loop, only thread consumed |
| 2–4 | KnitBalaclavaFull (research a balaclava) | 30 XP / 1 Yarn beats everything |
| 5 | SewLongjohns | 45 XP / 5 Thread + 5 Cotton (cotton from cutting sheets, ~free) — same 9 XP/thread as sack but 5× faster |
| 6 | SewLeatherGloves | 68 XP / 2 HeavyThread + 1 small hide — best XP per heavy-thread |
| 7+ | MakeWesternBoots | 80 XP / 2 HeavyThread + 1 medium hide + 1 plank |

---

## Quick playbook

1. **Lvl 0 → 1**: Spam SewRagBandana while ripping every clothing item you find. Read any Tailoring 1 mag for ×3.
2. **Lvl 1 → 3**: Set up sack loop (BurlapPiece + Thread → Bag_Gunny → BurlapPiece). Pick thread from rags between cycles. Knit beanies if you researched.
3. **Lvl 3 → 4**: SewTrousers — auto-learns at 5 even, available immediately at 3. FabricRolls from cutting sheets, thread from picking.
4. **Lvl 4 → 5**: SewBear if you have a wool/cotton stockpile. Otherwise grind Trousers or hide gear.
5. **Lvl 5 → 6**: Longjohns (clean sustainable). Bandolier if you have leather strips piling up.
6. **Lvl 6 → 7**: SewLeatherGloves nonstop. Tan everything you kill.
7. **Lvl 7 → 10**: Western Boots (most reliable inputs) or hunt PackFrames for Advanced Framepacks.

Read every Tailoring magazine you find before grinding — the multiplier dwarfs any recipe optimization.
