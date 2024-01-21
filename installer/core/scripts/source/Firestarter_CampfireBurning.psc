ScriptName Firestarter_CampfireBurning extends ObjectReference
{comment here}

ObjectReference function formForState(int which) native
function handleTimerFired(Form original) native
float function getStateDuration(int which) native
function takeControl(ObjectReference objref) native

ObjectReference property pOriginalForm Auto
ObjectReference property pCurrentForm Auto
ObjectReference property pCurrentRef Auto
int property pState = 0 auto


event OnActivate(ObjectReference akActionRef)
	pOriginalForm = akActionRef
	;takeControl(akActionRef)
	Debug.Notification("Hello world " + akActionRef.GetFormID())
endEvent

event onTakeControl()
	; record useful starting info
	pOriginalForm = pCurrentRef
endEvent

event transitionToState(int newState)
	; the new look
	ObjectReference newForm = formForState(newState)
	float scale = pOriginalForm.getScale()
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

Event OnUpdateGameTime()
	; poke native code to update to next state
	handleTimerFired(pOriginalForm)
EndEvent

event onReleaseControl()
	; clean up
endEvent
