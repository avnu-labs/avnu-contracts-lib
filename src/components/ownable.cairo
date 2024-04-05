use starknet::ContractAddress;

#[starknet::interface]
pub trait IOwnable<TContractState> {
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
}

#[starknet::component]
pub mod OwnableComponent {
    use core::num::traits::Zero;
    use starknet::{ContractAddress, get_caller_address};
    use super::IOwnable;

    #[storage]
    struct Storage {
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    struct OwnershipTransferred {
        #[key]
        previous_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress,
    }

    #[embeddable_as(OwnableImpl)]
    pub impl Ownable<TContractState, +HasComponent<TContractState>> of IOwnable<ComponentState<TContractState>> {
        fn get_owner(self: @ComponentState<TContractState>) -> ContractAddress {
            self.owner.read()
        }

        fn transfer_ownership(ref self: ComponentState<TContractState>, new_owner: ContractAddress) {
            assert(!new_owner.is_zero(), 'New owner is the zero address');
            self.assert_only_owner();
            self.set_owner(new_owner);
        }
    }

    #[generate_trait]
    pub impl OwnableInternalImpl<TContractState, +HasComponent<TContractState>> of OwnableInternal<TContractState> {
        fn initialize(ref self: ComponentState<TContractState>, owner: ContractAddress) {
            assert(!owner.is_zero(), 'New owner is the zero address');
            assert(self.get_owner().is_zero(), 'Owner already initialized');
            self.set_owner(owner);
        }

        fn assert_only_owner(self: @ComponentState<TContractState>) {
            let owner = self.get_owner();
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is the zero address');
            assert(caller == owner, 'Caller is not the owner');
        }
    }

    #[generate_trait]
    impl PrivateImpl<TContractState, +HasComponent<TContractState>> of PrivateTrait<TContractState> {
        fn set_owner(ref self: ComponentState<TContractState>, new_owner: ContractAddress) {
            let previous_owner = self.get_owner();
            self.owner.write(new_owner);
            self.emit(OwnershipTransferred { previous_owner, new_owner });
        }
    }
}
