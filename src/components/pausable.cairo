#[starknet::interface]
pub trait IPausable<TContractState> {
    fn is_paused(self: @TContractState) -> bool;
    fn pause(ref self: TContractState);
    fn unpause(ref self: TContractState);
}

#[starknet::component]
pub mod PausableComponent {
    use avnu_lib::components::ownable::OwnableComponent::OwnableInternalImpl;
    use avnu_lib::components::ownable::OwnableComponent;
    use starknet::ContractAddress;
    use super::IPausable;

    #[storage]
    struct Storage {
        paused: bool
    }

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {
        Paused: Paused,
        Unpaused: Unpaused,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Paused {}

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Unpaused {}

    pub mod Errors {
        pub const PAUSED: felt252 = 'Pausable: paused';
        pub const NOT_PAUSED: felt252 = 'Pausable: not paused';
    }

    #[embeddable_as(PausableImpl)]
    impl Pausable<
        TContractState, +HasComponent<TContractState>, impl Ownable: OwnableComponent::HasComponent<TContractState>, +Drop<TContractState>
    > of IPausable<ComponentState<TContractState>> {
        fn is_paused(self: @ComponentState<TContractState>) -> bool {
            self.paused.read()
        }

        fn pause(ref self: ComponentState<TContractState>) {
            get_dep_component!(@self, Ownable).assert_only_owner();
            self.assert_not_paused();
            self.paused.write(true);
            self.emit(Paused {});
        }

        fn unpause(ref self: ComponentState<TContractState>) {
            get_dep_component!(@self, Ownable).assert_only_owner();
            self.assert_paused();
            self.paused.write(false);
            self.emit(Unpaused {});
        }
    }

    #[generate_trait]
    pub impl PausableInternalImpl<TContractState, +HasComponent<TContractState>> of InternalTrait<TContractState> {
        fn assert_not_paused(self: @ComponentState<TContractState>) {
            assert(!self.paused.read(), Errors::PAUSED);
        }
        fn assert_paused(self: @ComponentState<TContractState>) {
            assert(self.paused.read(), Errors::NOT_PAUSED);
        }
    }
}
