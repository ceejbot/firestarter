ScriptName Firestarter_Activator extends ObjectReference
{An attempt at a no-state activator.}

; Game data we need to use for all of them.
Sound property pFailureSound auto
MiscObject property Firewood01 auto

; Activator-specific data, set in the CK.
bool property pActivationAdvancesState auto
bool property pActivationCostsFirewood auto
; should be a property, but hard-coding for now
int kFirewoodCost = 3
Activator property pActivationState auto

; Does this campfire state have a timer?
bool property pHasTimer auto
float property pTimerLen auto ; this is in days
Activator property pTimerState auto

Sound property pInitializationSound auto

; instance-specific data
bool isInitialized = false

; Called when the player activates the item, and also when this is
; first instantiated in the world.
event OnActivate(ObjectReference akActionRef)
    if !isInitialized
        if pInitializationSound != None
            pInitializationSound.Play(Game.GetPlayer())
        endIf
        if pHasTimer
            RegisterForSingleUpdateGameTime(1.0)
        endif
        isInitialized = true
        return
    endIf

    ; This block is player activation
    if pActivationAdvancesState
        if pActivationCostsFirewood
            ; if player has 3 firewood, take them & fuel the fire
            if Game.GetPlayer().GetItemCount(Firewood01) > kFirewoodCost
                Game.GetPlayer().RemoveItem(Firewood01, kFirewoodCost)
                replaceSelf(pActivationState)
            else
                ; play failure sound
            endif
        else
            replaceSelf(pActivationState)
        endif
        ; There might be an else here to handle cooking. IDEK.
    endIf
endEvent


Event OnUpdateGameTime()
    debug.Notification("OnUpdateGameTime()")
    replaceSelf(pTimerState)
EndEvent

function replaceSelf(Activator next)
    ObjectReference nextState = self.placeAtMe(next)
	nextState.SetScale(self.getScale())
	nextState.SetAngle(self.GetAngleX(), self.GetAngleY(), self.GetAngleZ())
	nextState.SetPosition(self.GetPositionX(), self.GetPositionY(), self.GetPositionZ())
	self.Disable()
	nextState.Enable()
    nextState.Activate(self)
	Debug.Notification("Finished updating appearance to " + next.GetFormID())
    self.DeleteWhenAble()
endFunction
