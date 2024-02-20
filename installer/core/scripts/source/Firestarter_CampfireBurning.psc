ScriptName Firestarter_CampfireBurning extends ObjectReference
{Managing campfires, the painfully papyral way.}

; filled in for us by the CK setup
string property pInitialState auto
Form property pInitialForm auto
ObjectReference property pOriginalRef auto

; We set these in advance in the CK.
MiscObject property Firewood01 auto
Furniture property pCookingPot auto
Furniture property pCookingStone auto

; the statics/nifs/etc that make up each state
Static property pColdForm auto
Static property pUnlitEmptyForm auto
Static property pUnlitFueledForm auto
ObjectReference property pKindledForm auto
ObjectReference property pBurningForm auto
ObjectReference property pRoaringForm auto
ObjectReference property pDyingForm auto
ObjectReference property pEmbersForm auto

; a local var
ObjectReference pCurrentRef

event OnActivate(ObjectReference akActionRef)
	Form base = akActionRef.GetBaseObject()
	pOriginalRef = akActionRef
	pInitialForm = base ; needed?

	Debug.Notification("Taking control " + base.GetFormID() + " " + akActionRef.GetFormID())
	GoToState(pInitialState)
endEvent

function updateAppearance(Form newForm)
	float scale = pOriginalRef.getScale()
	ObjectReference oldRef = pCurrentRef
	ObjectReference newStateRef = oldRef.placeAtMe(newForm)
	newStateRef.SetScale(scale)
	newStateRef.SetAngle(oldRef.GetAngleX(), oldRef.GetAngleY(), oldRef.GetAngleZ())

	oldRef.disable()
	newStateRef.enable()
	pCurrentRef = newStateRef
endFunction

state State_Cold

	event onBeginState()
		if (pInitialState == "State_Cold")
			return
		endif
		updateAppearance(pColdForm)
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
		updateAppearance(pUnlitEmptyForm)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; if player has 3 firewood, take them & fuel the fire
		Game.GetPlayer().RemoveItem(Firewood01, 3)
		GoToState("State_UnlitFueled")
	endEvent

endState

state State_UnlitFueled
	event onBeginState()
		if (pInitialState == "State_UnlitFueled")
			return
		endif
		updateAppearance(pUnlitFueledForm)
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

		updateAppearance(pKindledForm)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; might consider stoking to move it faster to next state?
	endEvent

	Event OnUpdateGameTime()
		GoToState("State_Burning")
	EndEvent

endState

state State_Burning
	event onBeginState()
		RegisterForSingleUpdateGameTime(8.0)
		; pCookingPot

		if (pInitialState == "State_Burning")
			return
		endif
		updateAppearance(pBurningForm)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		Game.GetPlayer().RemoveItem(Firewood01, 3)
		UnregisterForUpdateGameTime()
		GoToState("State_Roaring")
	endEvent

	Event OnUpdateGameTime()
		GoToState("State_Dying")
	EndEvent

endState

state State_Roaring
	event onBeginState()
		RegisterForSingleUpdateGameTime(4.0)
		if (pInitialState == "State_Roaring")
			return
		endif
		updateAppearance(pRoaringForm)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; just cook
	endEvent

	Event OnUpdateGameTime()
		GoToState("State_Burning")
	EndEvent

endState

state State_Dying
	event onBeginState()
		RegisterForSingleUpdateGameTime(5.0)
		if (pInitialState == "State_Dying")
			return
		endif

		updateAppearance(pDyingForm)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; if dynamic key down, douse
		; if not down, add fuel
		Game.GetPlayer().RemoveItem(Firewood01, 3)
		UnregisterForUpdateGameTime()
		GoToState("State_Burning")
	endEvent

	Event OnUpdateGameTime()
		GoToState("State_Embers")
	EndEvent

endState

state State_Embers
	event onBeginState()
		RegisterForSingleUpdateGameTime(3.0)
		if (pInitialState == "State_Embers")
			return
		endif
		; update keywords & forms etc

		updateAppearance(pEmbersForm)
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
		GoToState("State_Cold")
	EndEvent

endState
