ScriptName Firestarter_CampfireBurning extends ObjectReference
{Managing campfires, the painfully papyral way.}

; filled in for us by the CK setup
string property pInitialState auto
Form property pInitialForm auto
ObjectReference property pOriginalRef auto

; Campfire + log states
ObjectReference property pFS_State_Clean auto
ObjectReference property pFS_State_Fueled auto
ObjectReference property pFS_State_Kindled auto
ObjectReference property pFS_State_Burning auto
ObjectReference property pFS_State_Roaring auto
ObjectReference property pFS_State_Dying auto
ObjectReference property pFS_State_Ashes auto

; Sounds
Sound property pKindleSound auto
Sound property pFizzleSound auto

; Fire & glow effects.
ObjectReference property FXFireWithEmbersLight auto
ObjectReference property FXFireWithEmbersHeavy auto
ObjectReference property FXFireWithEmbersOut auto

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
	mCurrentModel = akActionRef
	pOriginalRef = akActionRef
	pInitialForm = base ; needed?

	Debug.Notification("Taking control; initial state " + pInitialState)
	GoToState(pInitialState)
endEvent

function updateAppearance(ObjectReference model, ObjectReference effect = None)
	ObjectReference newModel = self.placeAtMe(model)
	newModel.SetScale(self.getScale())
	newModel.SetAngle(self.GetAngleX(), self.GetAngleY(), self.GetAngleZ())
	newModel.SetPosition(self.GetPositionX(), self.GetPositionY(), self.GetPositionZ())
	mCurrentModel.Disable()
	; newModel.Enable()
	mCurrentModel = newModel

	if (effect != None)
		ObjectReference newEffect = mCurrentEffect.placeAtMe(effect)
		newEffect.Enable(true)
		mCurrentEffect.Disable(true)
		mCurrentEffect = newEffect
	Else
		mCurrentEffect.Disable(true)
	endIf

	Debug.Notification("Finished updating appearance to " + model.GetFormID())
endFunction

state State_Cold

	event onBeginState()
		if (pInitialState == "State_Cold")
			return
		endif
		pFizzleSound.Play(Game.GetPlayer())
		updateAppearance(pFS_State_Ashes, None)
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
		updateAppearance(pFS_State_Clean)
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
		updateAppearance(pFS_State_Fueled)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; check requirements
		; light fire
		Debug.Notification("kindling fire")
		GoToState("State_Kindled")
	endEvent

endState

state State_Kindled
	event onBeginState()
		pKindleSound.Play(Game.GetPlayer())
		RegisterForSingleUpdateGameTime(1.0)
		if (pInitialState == "State_Kindled")
			return
		endif
		updateAppearance(pFS_State_Kindled, FXFireWithEmbersLight)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		Debug.Notification("kindled state has no activate")
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
		updateAppearance(pFS_State_Burning, FXFireWithEmbersLight)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		Debug.Notification("adding more logs to fire")

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
		updateAppearance(pFS_State_Roaring, FXFireWithEmbersHeavy)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; just cook
	endEvent

	Event OnUpdateGameTime()
		debug.Notification("Roaring subsiding to state burning")
		GoToState("State_Burning")
	EndEvent

endState

state State_Dying
	event onBeginState()
		RegisterForSingleUpdateGameTime(kDyingHours)
		if (pInitialState == "State_Dying")
			return
		endif
		updateAppearance(pFS_State_Dying, FXFireWithEmbersLight)
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
		debug.Notification("Going to state dead")
		GoToState("State_Cold")
	EndEvent

endState

; Unused for now
state State_Embers
	event onBeginState()
		RegisterForSingleUpdateGameTime(kDyingHours)
		if (pInitialState == "State_Embers")
			return
		endif
		updateAppearance(pFS_State_Dying)
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
