#[starknet::contract]
pub mod WhitelistMock {
    use avnu_lib::components::ownable::OwnableComponent::OwnableInternalImpl;
    use avnu_lib::components::ownable::OwnableComponent;
    use avnu_lib::components::whitelist::WhitelistComponent;
    use starknet::ContractAddress;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: WhitelistComponent, storage: whitelist, event: WhitelistEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

    #[abi(embed_v0)]
    impl WhitelistImpl = WhitelistComponent::WhitelistImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        whitelist: WhitelistComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        WhitelistEvent: WhitelistComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.ownable.initialize(owner);
    }
}
