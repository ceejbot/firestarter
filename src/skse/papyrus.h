#pragma once

namespace papyrus
{
	void registerNativeFunctions();
	bool callback(RE::BSScript::IVirtualMachine* a_vm);

	void takeControl(RE::TESQuest*, RE::FormID formid, int initialState);
	const RE::TESObjectREFR* formForState(RE::TESQuest*, int which);
	void handleTimerFired(RE::TESQuest*, RE::FormID formid, int currentState);
	float getStateDuration(RE::TESQuest*, int which);


	// A contrived example.
	int stringToInt(RE::TESQuest*, RE::BSFixedString number);
};
