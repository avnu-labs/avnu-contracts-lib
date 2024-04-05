use starknet::ContractAddress;

#[starknet::interface]
pub trait IWhitelist<TContractState> {
    fn is_whitelisted(self: @TContractState, address: ContractAddress) -> bool;
    fn set_whitelisted_address(ref self: TContractState, address: ContractAddress, value: bool) -> bool;
}

#[starknet::component]
pub mod WhitelistComponent {
    use avnu_lib::components::ownable::OwnableComponent::OwnableInternalImpl;
    use avnu_lib::components::ownable::OwnableComponent;
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        whitelisted_addresses: LegacyMap<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {}

    #[embeddable_as(WhitelistImpl)]
    pub impl Whitelist<
        TContractState, +HasComponent<TContractState>, impl Ownable: OwnableComponent::HasComponent<TContractState>, +Drop<TContractState>
    > of super::IWhitelist<ComponentState<TContractState>> {
        fn is_whitelisted(self: @ComponentState<TContractState>, address: ContractAddress) -> bool {
            self.whitelisted_addresses.read(address)
        }

        fn set_whitelisted_address(ref self: ComponentState<TContractState>, address: ContractAddress, value: bool) -> bool {
            get_dep_component!(@self, Ownable).assert_only_owner();
            self.whitelisted_addresses.write(address, value);
            true
        }
    }
}
