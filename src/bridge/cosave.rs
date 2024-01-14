//! The rust side of cosave serialization. Tips follow.
//!
//! The most important tip I have for you is that you should decouple
//! your save types from your live-in-game types. You will make frequent
//! changes to the live types and you do not want to have to bump your
//! cosave version every time you add a new field to a struct. You need
//! to be able to read every single older version of the format you've written
//! to a save file, or your plugin releases won't be backcompat and your
//! users will be sad.
//!
//! Make a minimal save type using nothing but basic Rust built-in types.
//! Implement `From<LiveGameType>` for your save type. Serialize the
//! save type using whatever method you want that produces a `Vec<u8>`.
//! I use bincode for this, but you might choose something else.
//! Staying small is a friendly thing to do for your user's cosaves.
//! serde's derive macros are your friend.

use cxx::CxxVector;

/// Return the plugin's current cosave format version.
/// Versioning is left as an exercise for the reader (hint below).
pub fn cosave_data_version() -> u32 {
    version_01::COSAVE_FORMAT
}

/// Do whatever you'd like to do to serialize your plugin's data
/// to bytes. See suggestions above.
pub fn cosave_data() -> Vec<u8> {
    version_01::serialize()
}

/// SKSE has loaded your cosave data, and now you must deserialize it.
pub fn cosave_loaded(ffi_bytes: &CxxVector<u8>, version: u32) {
    // Gear-change from the bridge vec of bytes to the native Rust type.
    let bytes: Vec<u8> = ffi_bytes.iter().copied().collect();

    match version {
        version_01::COSAVE_FORMAT => {
            version_01::deserialize(bytes.as_slice());
        }
        _ => {
            log::warn!("Unknown cosave data version {version}! Cannot load save data.");
        }
    }
}

// types TKTK
mod version_01 {
    pub const COSAVE_FORMAT: u32 = 1;

    pub fn serialize() -> Vec<u8> {
        todo!()
    }

    pub fn deserialize(_bytes: &[u8]) {
        todo!()
    }
}
