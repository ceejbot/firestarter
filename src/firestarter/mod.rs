//! The rust logic parts.

use crate::plugin::{registerForTimeUpdateAt, TESForm};

use std::sync::Mutex;
use std::{collections::HashMap, time};

use cxx::let_cxx_string;
use once_cell::sync::Lazy;

/// There can be only one. Not public because we want access managed.
static CONTROLLER: Lazy<Mutex<Firestarter>> = Lazy::new(|| Mutex::new(Firestarter::new()));

pub fn get() -> std::sync::MutexGuard<'static, Firestarter> {
    CONTROLLER.lock().expect(
        "Unrecoverable runtime problem: cannot acquire firestarter controller lock. Exiting.",
    )
}

/// The thing wot manages all the campfires.
#[derive(Debug)]
pub struct Firestarter {
    fires: HashMap<u32, ManagedFire>,
}

impl Firestarter {
    pub fn new() -> Self {
        Self {
            fires: HashMap::new(),
        }
    }

    /// Take control of the passed-in fire.
    pub fn take_control(&mut self, form: &TESForm) {
        // create fire struct from args
        // add to fires hashmap

        let formid = form.GetFormID();
        let campfire = ManagedFire::new();
        self.fires.insert(formid, campfire);
        log::info!("taking control of campfire; obj ref {:x}", formid);

        todo!()
    }

    /// Relinquish control of the passed-in campfire form and scrub it from our memory.
    pub fn release_control(&mut self) {
        // restore to orginal state
        // remove from hashmap
        todo!()
    }
}

#[derive(Debug, Clone, Copy, Hash, PartialEq)]
pub enum FireState {
    /// Ashes and debris, no warmth.
    Cold,
    /// Empty of ashes and debris, no warmth.
    UnlitEmpty,
    /// Fresh logs, not burning. No warmth.
    UnlitFueled,
    /// Lit and starting to burn, small warmth.
    Kindled,
    /// Burning normally. Normal warmth.
    Burning,
    /// Burning with extra fuel. High warmth.
    Roaring,
    /// Fuel expiring. Moderate warmth.
    Dying,
    /// Fuel consumed. Low warmth.
    Embers,
}

impl FireState {
    /// Get the form id for this state's mesh.
    pub fn mesh(&self) -> u32 {
        todo!()
    }

    // get configured duration for this state, e.g., fire burns for 8 in-game hours
    // 1.0 f32 is 1 game hour
    pub fn duration(&self) -> f32 {
        match (&self) {
            FireState::Cold => 0.0,
            FireState::UnlitEmpty => 0.0,
            FireState::UnlitFueled => 0.0,
            FireState::Kindled => 0.5,
            FireState::Burning => 8.0,
            FireState::Roaring => 4.0,
            FireState::Dying => 3.0,
            FireState::Embers => 5.0,
        }
    }

    pub fn next(&self) -> Option<FireState> {
        match self {
            FireState::Cold => None,        // requires player action  to move from
            FireState::UnlitEmpty => None,  // requires player action
            FireState::UnlitFueled => None, // requires player action
            FireState::Kindled => Some(FireState::Burning),
            FireState::Burning => Some(FireState::Dying),
            FireState::Roaring => Some(FireState::Burning),
            FireState::Dying => Some(FireState::Embers),
            FireState::Embers => Some(FireState::Cold),
        }
    }
}

#[derive(Debug, Clone, Copy, Hash)]
pub struct ManagedFire {
    lastchange: time::Instant,
    state: FireState,
    // include game data
    /// ID of original form
    original: u32,
    original_state: FireState, // maybe
                               // gameref somehow
}

impl ManagedFire {
    /// Start managing a campfire object.
    pub fn new() -> Self {
        todo!()
    }

    pub fn formspec(&self) -> String {
        // return form spec of game item to frob
        todo!()
    }

    pub fn advance_state(&mut self) {
        let Some(next) = self.state.next() else {
            return;
        };
        self.change_state(&next);
    }

    /// Set this campfire's new state. Update its appearance.
    pub fn change_state(&mut self, new_state: &FireState) {
        // change appearance TODO

        let next_update = new_state.duration();
        if next_update > 0.0 {
            let_cxx_string!(formspec = self.formspec());
            registerForTimeUpdateAt(&formspec, next_update);
        }

        todo!()
    }

    pub fn state(&self) -> &FireState {
        &self.state
    }

    pub fn restore_original(&mut self) {
        todo!()
    }

    // current fuel
    // remaining time for current state
}

// Frostfall/survival mode warmth keywords
