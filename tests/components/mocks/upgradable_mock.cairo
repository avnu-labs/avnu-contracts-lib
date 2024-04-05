#[starknet::contract]
pub mod UpgradableMock {
    use avnu_lib::components::ownable::OwnableComponent::OwnableInternalImpl;
    use avnu_lib::components::ownable::OwnableComponent;
    use avnu_lib::components::upgradable::UpgradableComponent;
    use starknet::ContractAddress;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: UpgradableComponent, storage: upgradable, event: UpgradableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

    #[abi(embed_v0)]
    impl UpgradableImpl = UpgradableComponent::UpgradableImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        upgradable: UpgradableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        UpgradableEvent: UpgradableComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.ownable.initialize(owner);
    }
}
