#include "util.h"

#include "lib.rs.h"

namespace util
{

	constexpr auto dynamic_name = "dynamic";
	constexpr auto delimiter    = "|";

	constexpr RE::FormID unarmed = 0x000001F4;

	// How you know I've been replaced by a pod person: if I ever declare that
	// I love dealing with strings in systems programming languages.

	// The Cxx bridge wants us to use Vec<u8> for transferring bags of bytes,
	// not a pointer to char with a null at the end.
	std::vector<uint8_t> chars_to_vec(const char* input)
	{
		if (!input) { return std::move(std::vector<uint8_t>()); }
		auto incoming_len = strlen(input);
		if (incoming_len == 0) { return std::move(std::vector<uint8_t>()); }

		std::vector<uint8_t> result;
		result.reserve(incoming_len + 1);  // null terminator
		for (auto* ptr = input; *ptr != 0; ptr++) { result.push_back(static_cast<uint8_t>(*ptr)); }
		result.push_back(0x00);  // there it is
		return std::move(result);
	}

	// Decode a wild-west item name to utf-8.
	std::string nameAsUtf8(const RE::TESForm* form)
	{
		auto name     = form->GetName();
		auto chonker  = chars_to_vec(name);
		auto safename = std::string(cstr_to_utf8(chonker));
		return safename;
	}

	// Post a text notification to the screen.
	void notifyPlayer(const std::string& message)
	{
		auto* msg = message.c_str();
		RE::DebugNotification(msg);
	}

	// Look up a scaleform translation by key.
	rust::String lookupTranslation(const std::string& key)
	{
		std::string translated = std::string();
		SKSE::Translation::Translate(key, translated);
		return translated;
	}

	void registerForTimeUpdateAt(const std::string& form_spec, float wait)
	{
		auto* const item = formSpecToFormItem(form_spec);
		if (!item) { return; }
		SKSE::ModCallbackEvent modEvent{ "SoulsyRegisterForUpdate", {}, wait, item };
		SKSE::GetModCallbackEventSource()->SendEvent(&modEvent);
	}

	RE::TESForm* formSpecToFormItem(const std::string& a_str)
	{
		if (a_str.empty())
		{
			// rlog::debug("formSpecToFormItem() got empty string; this can never return an item.");
			return nullptr;
		}


		if (!a_str.find(delimiter)) { return nullptr; }
		RE::TESForm* form;

		std::istringstream string_stream{ a_str };
		std::string plugin, id;

		std::getline(string_stream, plugin, *delimiter);
		std::getline(string_stream, id);
		RE::FormID form_id;
		// strip off 0x if present
		auto formline = std::istringstream(id);
		formline.ignore(2, 'x');
		formline >> std::hex >> form_id;

		if (plugin.empty())
		{
			rlog::warn("malformed form spec? spec={};"sv, a_str);
			return nullptr;
		}

		if (plugin == util::dynamic_name) { form = RE::TESForm::LookupByID(form_id); }
		else
		{
			const auto data_handler = RE::TESDataHandler::GetSingleton();
			form                    = data_handler->LookupForm(form_id, plugin);
		}

		// if (form != nullptr)
		// {
		// 	rlog::trace("found form id for form spec='{}'; name='{}'; formID={}",
		// 		a_str,
		// 		helpers::nameAsUtf8(form),
		// 		rlog::formatAsHex(form->GetFormID()));
		// }

		return form;
	}

}
