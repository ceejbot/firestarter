;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
ScriptName Firestarter_DAK_Perk extends Perk

Furniture property pCraftingFurniture auto

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akTargetRef, Actor akActor)
    ;BEGIN CODE

    Actor player = Game.GetPlayer()
    ObjectReference furnitureMarker = player.PlaceAtMe(pCraftingFurniture)
	furnitureMarker.Activate(player)

	int i = 0
	While !furnitureMarker.IsFurnitureInUse() && i < 50
		i += 1
		Utility.Wait(0.1)
	EndWhile

	While furnitureMarker.IsFurnitureInUse()
		Utility.Wait(1)
	EndWhile

	; This code is borrowed from Campfire & Hunterborn.
	If furnitureMarker
		furnitureMarker.Disable()
		Utility.Wait(0.1)
		furnitureMarker.Delete()
	EndIf

    ;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
