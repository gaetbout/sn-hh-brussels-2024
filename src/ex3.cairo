// Example coming directly from: 
// https://starknet-by-example.voyager.online/advanced-concepts/write_to_any_slot.html
#[starknet::interface]
pub trait IWriteToAnySlots<TContractState> {
    fn write_slot(ref self: TContractState, value: u32);
    fn read_slot(self: @TContractState) -> u32;
}

#[starknet::contract]
pub mod WriteToAnySlot {
    use starknet::syscalls::{storage_read_syscall, storage_write_syscall};
    use starknet::storage_access::{
        storage_base_address_from_felt252, storage_address_from_base,
        storage_address_from_base_and_offset
    };
    use starknet::SyscallResultTrait;

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl WriteToAnySlot of super::IWriteToAnySlots<ContractState> {
        fn write_slot(ref self: ContractState, value: u32) {
            let base = storage_base_address_from_felt252(selector!("test_slot"));
            let storage_address = storage_address_from_base_and_offset(base, 4);
            storage_write_syscall(0, storage_address, value.into()).unwrap_syscall();
        }

        fn read_slot(self: @ContractState) -> u32 {
            let base = storage_base_address_from_felt252(selector!("test_slot"));
            let storage_address = storage_address_from_base(base);
            storage_read_syscall(0, storage_address).unwrap_syscall().try_into().unwrap()
        }
    }
}
