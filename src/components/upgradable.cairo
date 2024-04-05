use starknet::ClassHash;

#[starknet::interface]
pub trait IUpgradable<TContractState> {
    fn upgrade_class(ref self: TContractState, new_class_hash: ClassHash);
}

#[starknet::component]
pub mod UpgradableComponent {
    use avnu_lib::components::ownable::OwnableComponent::OwnableInternalImpl;
    use avnu_lib::components::ownable::OwnableComponent;
    use core::num::traits::Zero;
    use starknet::SyscallResultTrait;
    use starknet::syscalls::replace_class_syscall;
    use starknet::{ClassHash, get_caller_address};
    use super::IUpgradable;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {
        Upgraded: Upgraded
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Upgraded {
        pub class_hash: ClassHash
    }

    #[embeddable_as(UpgradableImpl)]
    pub impl Upgradable<
        TContractState, +HasComponent<TContractState>, impl Ownable: OwnableComponent::HasComponent<TContractState>, +Drop<TContractState>
    > of IUpgradable<ComponentState<TContractState>> {
        fn upgrade_class(ref self: ComponentState<TContractState>, new_class_hash: ClassHash) {
            assert(!new_class_hash.is_zero(), 'Class hash cannot be zero');
            get_dep_component!(@self, Ownable).assert_only_owner();
            replace_class_syscall(new_class_hash).unwrap_syscall();
            self.emit(Upgraded { class_hash: new_class_hash });
        }
    }
}
