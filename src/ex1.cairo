#[starknet::interface]
pub trait IMyInterface<TContractState> {
    fn set_value(ref self: TContractState, value: u64);
    fn get_value(self: @TContractState) -> u64;
}

#[starknet::contract]
mod Calling {
    use super::{
        IMyInterface, IMyInterfaceDispatcher, IMyInterfaceDispatcherTrait,
        IMyInterfaceLibraryDispatcher
    };
    use starknet::{ContractAddress, ClassHash};

    #[storage]
    struct Storage {
        contract_address: ContractAddress,
        dispatcher: IMyInterfaceDispatcher
    }

    #[constructor]
    fn constructor(ref self: ContractState, contract_address: ContractAddress) {
        // Same thing
        self.contract_address.write(contract_address);
        self.dispatcher.write(IMyInterfaceDispatcher { contract_address });
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    // Using your own dispatcher
    #[abi(embed_v0)]
    impl MyImpl of IMyInterface<ContractState> {
        fn set_value(ref self: ContractState, value: u64) {
            IMyInterfaceDispatcher { contract_address: self.contract_address.read() }
                .set_value(value);
            // Is the same as: 
            self.dispatcher.read().set_value(value);
            //
            // You can also access the contract address that way (if you store the dispatcher only)
            let _dispatcher_contract_address = self.dispatcher.read().contract_address;
        }

        fn get_value(self: @ContractState) -> u64 {
            self.dispatcher.read().get_value()
        }
    }

    // Using an external dispatcher
    use openzeppelin::token::erc20::interface::{IERC20, IERC20Dispatcher, IERC20DispatcherTrait};

    #[external(v0)]
    fn balance_of(
        self: @ContractState, token_address: ContractAddress, account: ContractAddress
    ) -> u256 {
        IERC20Dispatcher { contract_address: token_address }.balance_of(account)
    }
    // Both function are the same input 
    #[external(v0)]
    fn balance_of_dispatcher(
        self: @ContractState, dispatcher: IERC20Dispatcher, account: ContractAddress
    ) -> u256 {
        dispatcher.balance_of(account)
    }
// Dispatcher vs LibraryDispatcher vs SafeDispatcher
}
