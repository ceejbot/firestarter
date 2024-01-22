#include "papyrus.h"

#include "lib.rs.h"

namespace papyrus
{
	static const char* MCM_NAME = "firestarter";

	void registerNativeFunctions()
	{
		const auto* papyrus = SKSE::GetPapyrusInterface();
		papyrus->Register(callback);
	}

	/*
	ObjectReference function formForState(int which) native
function handleTimerFired(Form original) native
float function getStateDuration(int which) native
function takeControl(ObjectReference objref, int initialState) native
*/

	bool callback(RE::BSScript::IVirtualMachine* a_vm)
	{
		a_vm->RegisterFunction("StringToInt", MCM_NAME, stringToInt);
		a_vm->RegisterFunction("formForState", MCM_NAME, formForState);
		a_vm->RegisterFunction("getStateDuration", MCM_NAME, getStateDuration);
		a_vm->RegisterFunction("handleTimerFired", MCM_NAME, handleTimerFired);
		a_vm->RegisterFunction("takeControl", MCM_NAME, takeControl);
		return true;
	}

	void takeControl(RE::TESQuest*, RE::FormID formid, int initialState)
	{
		rlog::info("taking control of campfire {:#04x}; initial state={};", formid, initialState);
	}

	const RE::TESObjectREFR* formForState(RE::TESQuest*, int which)
	{
		const auto state = static_cast<uint8_t>(which);
		return &form_for_state(state);
	}

	void handleTimerFired(RE::TESQuest*, RE::FormID formid, int currentState)
	{
		const auto state = static_cast<uint8_t>(currentState);
		rlog::info("handleTimerFired({}, {})", formid, state);
		const auto* objectref = RE::TESForm::LookupByID(formid);
		handle_timer_fired(objectref, state);
	}

	float getStateDuration(RE::TESQuest*, int which) { return state_duration(static_cast<uint8_t>(which)); }


	int stringToInt(RE::TESQuest*, RE::BSFixedString number)
	{
		auto numstr = std::string(number);
		// Here we call a Rust function that we've pulled in from the bridge.
		return string_to_int(numstr);
	}
}
