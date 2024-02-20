ScriptName Firestarter_CampfireBurning extends ObjectReference
{comment here}

import PO3_SKSEFunctions

string property pInitialState auto
Form property pInitialForm auto

ObjectReference property pOriginalRef auto
MiscObject property Firewood01 auto

; the statics/nifs/etc that make up each state
Form property pColdForms[] auto
Form property pUnlitEmptyForms[] auto
Form property pUnlitFueledForms[] auto
Form property pKindledForms[] auto
Form property pBurningForms[] auto
Form property pRoaringForms[] auto
Form property pDyingForms[] auto
Form property pEmbersForms[] auto

ObjectReference[] property pCurrentRefs auto


; filled in for us
string property pState auto
Form property pCookingPot auto
Form property pCookingStone auto

event OnActivate(ObjectReference akActionRef)
	Form base = akActionRef.GetBaseObject()
	pOriginalRef = akActionRef
	pInitialForm = base ; needed?

	Debug.Notification("Taking control " + base.GetFormID() + " " + akActionRef.GetFormID())
	GoToState(pInitialState)
endEvent

function updateAppearance(Form[] newFormList)
	float scale = pOriginalRef.getScale()

	; These lists must have equal length in the CK.
	int i=0
    while (i < newFormList.length)
    	newForm = newFormList[i]

		ObjectReference newStateRef = pCurrentRef.placeAtMe(newForm)
		newStateRef.SetScale(scale)
		newStateRef.SetAngle(pCurrentRef.GetAngleX(), pCurrentRef.GetAngleY(), pCurrentRef.GetAngleZ())

		pCurrentRefs[i].disable()
		newStateRef.enable()
		pCurrentRefs[i] = newStateRef
        i+=1
    endwhile
endFunction

state State_Cold

	event onBeginState()
		if (pInitialState == "State_Cold")
			return
		endif
		updateAppearance(pColdForms)
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
		updateAppearance(pUnlitEmptyForms)
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
		updateAppearance(pUnlitFueledForms)
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

		updateAppearance(pKindledForms)
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
		updateAppearance(pBurningForms)
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
		updateAppearance(pRoaringForms)
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

		updateAppearance(pDyingForms)
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

		updateAppearance(pEmbersForms)
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
