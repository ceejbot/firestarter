//! Sometimes we want wrappers for the C++ functions we're calling.

use crate::plugin::{FireState, TESObjectREFR};
// a conditional use statement...
#[cfg(not(test))]
use crate::plugin::{lookupTranslation, notifyPlayer};

/// Convenience function for printing a message on the screen.
#[cfg(not(test))]
pub fn notify(msg: &str) {
    cxx::let_cxx_string!(message = msg);
    notifyPlayer(&message);
}

// Note the stub to prevent test compilation from trying to pull in the game dll.
#[cfg(test)]
pub fn notify(_msg: &str) {}

/// Convenience function for doing the cxx macro boilerplate before
/// calling C++ with a string.
#[cfg(not(test))]
pub fn translated_key(key: &str) -> String {
    cxx::let_cxx_string!(cxxkey = key);
    lookupTranslation(&cxxkey)
}

// Note the stub to prevent test compilation from trying to pull in the game dll.
#[cfg(test)]
pub fn translated_key(key: &str) -> String {
    format!("translation of {key}")
}

pub fn state_duration(which: u8) -> f32 {
    let state = FireState::from(which);
    state.duration()
}

pub fn handle_timer_fired(object: &TESObjectREFR, which: u8) {
    todo!()
}

pub fn form_for_state(which: u8) -> &'static TESObjectREFR {
    todo!()
}
