ScriptName Firestarter_CampfireBurning extends ObjectReference
{comment here}

; just sketching all this out for now

Form function formForState(int state) native
function handleTimerFired(Form original) native

Form property pOriginalForm Auto
Form property pCurrentForm Auto
ObjectReference pCurrentRef Auto
int property pState

event onTakeControl()
	; record useful starting info
	pOriginalForm = this
endEvent

event transitionToState(int newState)
	; the new look
	Form newForm = formForState(newState)
	float scale = oOriginalForm.getScale()
	ObjectReference newStateRef = pCurrentRef.placeAtMe(newForm)

	newStateRef.SetScale(scale)
	newStateRef.SetAngle(pCurrentRef.GetAngleX(), pCurrentRef.GetAngleY(), pCurrentRef.GetAngleZ())

	; todo call function to find out what this time should be
	RegisterForSingleUpdateGameTime(3.0)
endEvent

Event OnUpdateGameTime()
	; poke native code to update to next state
	handleTimerFired(pOriginalForm)
EndEvent

event onReleaseControl()
	; clean up
endEvent
