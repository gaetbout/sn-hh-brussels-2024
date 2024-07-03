// Example coming directly from: 
// https://starknet-by-example.voyager.online/advanced-concepts/struct-mapping-key.html

#[derive(Copy, Drop, Serde, Hash)]
pub struct Pet {
    pub name: felt252,
    pub age: u8,
    pub owner: felt252,
    pub species: Span<felt252>
}

use core::hash::{HashStateTrait, Hash};

impl HashFelt252<S, +Drop<S>, +HashStateTrait<S>> of Hash<Span<felt252>, S> {
    fn update_state(state: S, value: Span<felt252>) -> S {
        let mut value = value;
        let mut state = state.update(value.len().into());
        while let Option::Some(item) = value.pop_front() {
            state = state.update(*item);
        };
        state
    }
}

#[starknet::interface]
pub trait IPetRegistry<TContractState> {
    fn register_pet(ref self: TContractState, key: Pet, timestamp: u64);
    fn get_registration_date(self: @TContractState, key: Pet) -> u64;
}

#[starknet::contract]
pub mod PetRegistry {
    use core::hash::{HashStateTrait, Hash};
    use super::Pet;

    #[storage]
    struct Storage {
        registration_time: LegacyMap::<Pet, u64>,
    }

    #[abi(embed_v0)]
    impl PetRegistry of super::IPetRegistry<ContractState> {
        fn register_pet(ref self: ContractState, key: Pet, timestamp: u64) {
            self.registration_time.write(key, timestamp);
        }

        fn get_registration_date(self: @ContractState, key: Pet) -> u64 {
            self.registration_time.read(key)
        }
    }
}
