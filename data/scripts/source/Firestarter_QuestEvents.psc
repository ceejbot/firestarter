ScriptName Firestarter_QuestEvents extends ReferenceAlias

Actor property PlayerRef Auto
Perk property FS_DAK_Perk Auto

; This is the perk that allows us to conditionally check the dynamic
; activation key and trigger a different script fragment if it's pressed.
event onInit()
	PlayerRef.AddPerk(FS_DAK_Perk)
endEvent
