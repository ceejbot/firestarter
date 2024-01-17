#include "hooks.h"

// Maybe there are more than just the player hook you want to install?
void installFunctionHooks() { PlayerHook::install(); }

// ---------- PlayerHook

void PlayerHook::install()
{
	rlog::info("Hooking player so we get inventory changes..."sv);

	REL::Relocation<std::uintptr_t> player_character_vtbl{ RE::VTABLE_PlayerCharacter[0] };
	add_object_to_container_ = player_character_vtbl.write_vfunc(0x5A, itemAdded);
	pick_up_object_          = player_character_vtbl.write_vfunc(0xCC, itemPickedUp);
	remove_item_             = player_character_vtbl.write_vfunc(0x56, itemRemoved);

	auto& trampoline = SKSE::GetTrampoline();
	REL::Relocation<std::uintptr_t> add_item_functor_hook{ RELOCATION_ID(55946, 56490) };
	add_item_functor_ = trampoline.write_call<5>(add_item_functor_hook.address() + 0x15D, add_item_functor);
	rlog::info("Player hooked.");
}

void PlayerHook::itemAdded(RE::Actor* a_this,
	RE::TESBoundObject* object,
	RE::ExtraDataList* extraDataList,
	int32_t delta,
	RE::TESObjectREFR* a_from_refr)
{
	// call the original first
	add_object_to_container_(a_this, object, extraDataList, delta, a_from_refr);
	if (object->IsInventoryObject())
	{
		auto item_form = RE::TESForm::LookupByID(object->formID);
		notifyInventoryChanged(item_form);
	}
}

void PlayerHook::itemPickedUp(RE::Actor* actor,
	RE::TESObjectREFR* object,
	uint32_t delta,
	bool a_arg3,
	bool a_play_sound)
{
	// call the original first
	pick_up_object_(actor, object, delta, a_arg3, a_play_sound);
	if (object->GetBaseObject()->IsInventoryObject())
	{
		auto lookup = object->formID;
		if (lookup == 0) { lookup = object->GetBaseObject()->formID; }
		auto item_form = RE::TESForm::LookupByID(lookup);
		notifyInventoryChanged(item_form);
	}
}

RE::ObjectRefHandle PlayerHook::itemRemoved(RE::Actor* actor,
	RE::TESBoundObject* object,
	std::int32_t delta,
	RE::ITEM_REMOVE_REASON a_reason,
	RE::ExtraDataList* extraDataList,
	RE::TESObjectREFR* a_move_to_ref,
	const RE::NiPoint3* a_drop_loc,
	const RE::NiPoint3* a_rotate)
{
	// call the original and snag its return value before we do our thing
	auto retval = remove_item_(actor, object, delta, a_reason, extraDataList, a_move_to_ref, a_drop_loc, a_rotate);
	if (object->IsInventoryObject())
	{
		auto* item_form = RE::TESForm::LookupByID(object->formID);
		notifyInventoryChanged(item_form);
	}
	return retval;
}

void PlayerHook::add_item_functor(RE::TESObjectREFR* a_this, RE::TESObjectREFR* object, int32_t delta, bool a4, bool a5)
{
	add_item_functor_(a_this, object, delta, a4, a5);
	auto item_form = RE::TESForm::LookupByID(object->GetBaseObject()->formID);
	notifyInventoryChanged(item_form);
}

void PlayerHook::notifyInventoryChanged(RE::TESForm* item_form)
{
	if (!item_form) { return; }

	// note that we must make sure the item name is valid utf8 before we log it.
	// if we do not, we crash.
	const auto safename = util::nameAsUtf8(item_form);
	rlog::info("inventory change for item '{}'", safename);

	// pour your implementation of something useful to do here!
}
