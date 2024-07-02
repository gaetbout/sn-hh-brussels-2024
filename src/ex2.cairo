#[starknet::contract]
mod Upgrade {
    use core::result::ResultTrait;
    use starknet::ClassHash;
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
    fn upgrade(to: ClassHash) {
        // Do some access control
        // pre-checks
        starknet::syscalls::replace_class_syscall(to).unwrap();
        // Do some post-checks
        ()
    }
}
