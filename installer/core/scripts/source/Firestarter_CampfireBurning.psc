ScriptName Firestarter_CampfireBurning extends ObjectReference
{comment here}

;ObjectReference function formForState(int which) native
;function handleTimerFired(Form original) native
;float function getStateDuration(int which) native
;function takeControl(ObjectReference objref, int initialState) native

string property pInitialState Auto
Form property pInitialForm Auto

ObjectReference property pOriginalRef Auto
ObjectReference property pCurrentForm Auto
ObjectReference property pCurrentRef Auto
string property pState auto

event OnActivate(ObjectReference akActionRef)
	Form base = akActionRef.GetBaseObject()
	pOriginalRef = akActionRef
	pInitialForm = base ; needed?

	Debug.Notification("Taking control " + base.GetFormID() + " " + akActionRef.GetFormID())
	GoToState(pInitialState)

	; if firewood in inventory, offer stoke
	; also offer cook
	; put out
endEvent

event transitionToState(int newState)
	; the new look
	ObjectReference newForm = formForState(newState)
	float scale = pOriginalRef.getScale()
	ObjectReference newStateRef = pCurrentRef.placeAtMe(newForm)

	newStateRef.SetScale(scale)
	newStateRef.SetAngle(pCurrentRef.GetAngleX(), pCurrentRef.GetAngleY(), pCurrentRef.GetAngleZ())

	float duration = getStateDuration(newState)
	if (duration > 0)
		RegisterForSingleUpdateGameTime(duration)
	endif

	pCurrentRef.disable()
	newStateRef.enable()
	pCurrentRef.delete() ; is this a thing?

	pState = newState
	pCurrentForm = newStateRef
endEvent


state State_Cold

	event onBeginState()
		if (pInitialState == "State_Cold")
			return
		endif
		; update forms, keywords
		self.GetNthLinkedRef(1).MoveToMyEditorLocation()
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

	endEvent

	event OnActivate(ObjectReference akActionRef)
		; if player has 3 firewood, take them & fuel the fire
		GoToState("State_UnlitFueled")
	endEvent

endState

state State_UnlitFueled
	event onBeginState()
		if (pInitialState == "State_UnlitFueled")
			return
		endif

		; start timer
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; check requirements
		; light fire
		GoToState("State_Kindled")
	endEvent

endState

state State_Kindled
	event onBeginState()
		if (pInitialState == "State_Kindled")
			return
		endif

		RegisterForSingleUpdateGameTime(1.0)

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
		if (pInitialState == "State_Burning")
			return
		endif

		ObjectReference newForm = formForState(newState)
		float scale = pOriginalRef.getScale()
		ObjectReference newStateRef = pCurrentRef.placeAtMe(newForm)

		newStateRef.SetScale(scale)
		newStateRef.SetAngle(pCurrentRef.GetAngleX(), pCurrentRef.GetAngleY(), pCurrentRef.GetAngleZ())

		RegisterForSingleUpdateGameTime(8.0)

		pCurrentRef.disable()
		newStateRef.enable()
		pCurrentRef.delete() ; is this a thing?

		pCurrentForm = newStateRef
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; if dynamic key down, cook
		; if not down, add fuel
		; if we added fuel, then UnregisterForUpdateGameTime()
	endEvent

	Event OnUpdateGameTime()
		GoToState("State_Dying")
	EndEvent

endState

state State_Roaring
	event onBeginState()
		if (pInitialState == "State_Roaring")
			return
		endif

		RegisterForSingleUpdateGameTime(4.0)
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
		if (pInitialState == "State_Dying")
			return
		endif

		RegisterForSingleUpdateGameTime(5.0)

	endEvent

	event OnActivate(ObjectReference akActionRef)
		; if dynamic key down, douse
		; if not down, add fuel
		UnregisterForUpdateGameTime()
	endEvent

	Event OnUpdateGameTime()
		GoToState("State_Embers")
	EndEvent


endState

state State_Embers
	event onBeginState()
		if (pInitialState == "State_Embers")
			return
		endif
		; update keywords & forms etc

		RegisterForSingleUpdateGameTime(3.0)
	endEvent

	event OnActivate(ObjectReference akActionRef)
		; clean it out
		UnregisterForUpdateGameTime()
		GoToState("State_Cold")
	endEvent

	Event OnUpdateGameTime()
		GoToState("State_Cold")
	EndEvent

endState
