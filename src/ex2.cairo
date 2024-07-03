use starknet::ClassHash;

#[starknet::interface]
trait IUpgradableCallback<TContractState> {
    fn after_upgrade(ref self: TContractState, new_implementation: ClassHash, data: Span<felt252>);
}

#[starknet::contract]
mod Upgrade {
    use core::result::ResultTrait;
    use starknet::ClassHash;
    use super::{IUpgradableCallbackLibraryDispatcher, IUpgradableCallbackDispatcherTrait};

    #[storage]
    struct Storage {}
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    // Difference between Contract Class (ClassHash) and Instance (ContractAddress)
    // https://docs.starknet.io/architecture-and-concepts/smart-contracts/contract-classes/

    // Upgradable no more proxy, replace_syscall

    #[constructor]
    fn constructor(ref self: ContractState) {}

    // No more proxy, it is just built-in
    fn upgrade(new_implementation: ClassHash, data: Array<felt252>) {
        // Access control
        // pre-checks
        starknet::syscalls::replace_class_syscall(new_implementation).unwrap();
        // Do some post-checks
        IUpgradableCallbackLibraryDispatcher { class_hash: new_implementation }
            .after_upgrade(new_implementation, data.span());
    }
}
