ScriptName Firestarter_CampfireBurning extends ObjectReference
{Managing campfires, the painfully papyral way.}

; filled in for us by the CK setup
string property pInitialState auto
Form property pInitialForm auto
ObjectReference property pOriginalRef auto

; the statics/nifs/etc that make up each state
Static property Campfire01LandOff auto ; needs to be renamed to generic
ObjectReference property Campfire01LandBurning auto ; needs to be renamed generically
ObjectReference property FXFireWithEmbersLogs01 auto
ObjectReference property FXFireWithEmbersOut auto
ObjectReference property FXFireWithEmbersLight auto
ObjectReference property FXFireWithEmbersHeavy auto

; Campfire + log states
ObjectReference property FS_State_Clean auto
ObjectReference property FS_State_Fueled auto
ObjectReference property FS_State_Kindled auto
ObjectReference property FS_State_Burning auto
ObjectReference property FS_State_Roaring auto
ObjectReference property FS_State_Dying auto
ObjectReference property FS_State_Ashes auto

; We set these in advance in the CK.
MiscObject property Firewood01 auto
Furniture property CraftingCookingPotSmNoHandle auto
Furniture property FS_Furn_CookingStone auto

; local state vars
ObjectReference mCurrentModel
ObjectReference mCurrentEffect

float kBurningHours = 1.0
float kRoaringHours = 1.0
float kDyingHours = 1.0
int kFirewoodCost = 3

event OnActivate(ObjectReference akActionRef)
	Form base = akActionRef.GetBaseObject()
	pOriginalRef = akActionRef
	pInitialForm = base ; needed?

	Debug.Notification("Taking control " + base.GetFormID() + " " + akActionRef.GetFormID())
	GoToState(pInitialState)
endEvent

function updateAppearance(Form model, ObjectReference effect)
	float scale = pOriginalRef.getScale()
	ObjectReference oldModel = mCurrentModel
	ObjectReference oldEffect = mCurrentEffect
	ObjectReference newModel = oldModel.placeAtMe(model)
	ObjectReference newEffect = oldModel.placeAtMe(effect)
	newModel.SetScale(scale)
	newEffect.SetScale(scale)
	newModel.SetAngle(oldModel.GetAngleX(), oldModel.GetAngleY(), oldModel.GetAngleZ())

	oldModel.disable()
	newModel.enable()
	oldEffect.disable()
	newEffect.enable()
	mCurrentModel = newModel
	mCurrentEffect = newEffect
endFunction

state State_Cold

	event onBeginState()
		if (pInitialState == "State_Cold")
			return
		endif
		updateAppearance(Campfire01LandOff, FXFireWithEmbersOut)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; clean out the ashes; go to clean empty stones
		GoToState("State_UnlitEmpty")
	endEvent

endState

state State_UnlitEmpty
	event onBeginState()
		if (pInitialState == "State_UnlitEmpty")
			return
		endif
		updateAppearance(Campfire01LandOff, FXFireWithEmbersOut)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; if player has 3 firewood, take them & fuel the fire
		if Game.GetPlayer().GetItemCount(Firewood01) > kFirewoodCost
			Game.GetPlayer().RemoveItem(Firewood01, kFirewoodCost)
			GoToState("State_UnlitFueled")
		else
			; play failure sound
		endif
	endEvent

endState

state State_UnlitFueled
	event onBeginState()
		if (pInitialState == "State_UnlitFueled")
			return
		endif
		updateAppearance(Campfire01LandOff, FXFireWithEmbersOut)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; check requirements
		; light fire
		GoToState("State_Kindled")
	endEvent

endState

state State_Kindled
	event onBeginState()
		RegisterForSingleUpdateGameTime(1.0)
		if (pInitialState == "State_Kindled")
			return
		endif
		updateAppearance(Campfire01LandOff, FXFireWithEmbersLight)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; might consider stoking to move it faster to next state?
	endEvent

	Event OnUpdateGameTime()
		debug.Notification("Going to state burning")
		GoToState("State_Burning")
	EndEvent

endState

state State_Burning
	event onBeginState()
		RegisterForSingleUpdateGameTime(kBurningHours)
		; pCookingPot

		if (pInitialState == "State_Burning")
			return
		endif
		updateAppearance(Campfire01LandBurning, FXFireWithEmbersLight)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		if Game.GetPlayer().GetItemCount(Firewood01) > kFirewoodCost
			Game.GetPlayer().RemoveItem(Firewood01, kFirewoodCost)
			UnregisterForUpdateGameTime()
			GoToState("State_Roaring")
		else
			; play failure sound
		endif
	endEvent

	Event OnUpdateGameTime()
		debug.Notification("Going to state dying")
		GoToState("State_Dying")
	EndEvent

endState

state State_Roaring
	event onBeginState()
		RegisterForSingleUpdateGameTime(kRoaringHours)
		if (pInitialState == "State_Roaring")
			return
		endif
		updateAppearance(Campfire01LandBurning, FXFireWithEmbersHeavy)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; just cook
	endEvent

	Event OnUpdateGameTime()
		debug.Notification("Going to state burning")
		GoToState("State_Burning")
	EndEvent

endState

state State_Dying
	event onBeginState()
		RegisterForSingleUpdateGameTime(kDyingHours)
		if (pInitialState == "State_Dying")
			return
		endif
		updateAppearance(Campfire01LandOff, FXFireWithEmbersOut)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; if dynamic key down, douse
		; if not down, add fuel
		if Game.GetPlayer().GetItemCount(Firewood01) > kFirewoodCost
			Game.GetPlayer().RemoveItem(Firewood01, 3)
			UnregisterForUpdateGameTime()
			GoToState("State_Burning")
		else
			; play failure sound
		endif
	endEvent

	Event OnUpdateGameTime()
		debug.Notification("Going to state embers")
		GoToState("State_Embers")
	EndEvent

endState

state State_Embers
	event onBeginState()
		RegisterForSingleUpdateGameTime(kDyingHours)
		if (pInitialState == "State_Embers")
			return
		endif
		updateAppearance(Campfire01LandOff, FXFireWithEmbersOut)
		; apply keywords; might not need this if form has keywords already
		; AddKeywordToRef()
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; could re-kindle here instead but
		; clean it out
		UnregisterForUpdateGameTime()
		GoToState("State_Cold")
	endEvent

	Event OnUpdateGameTime()
		debug.Notification("Going to state cold")
		GoToState("State_Cold")
	EndEvent

endState
