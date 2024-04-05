use avnu_lib::components::upgradable::{IUpgradableDispatcherTrait, UpgradableComponent};
use starknet::class_hash::{class_hash_const, ClassHash};
use starknet::contract_address_const;
use starknet::testing::{pop_log_raw, set_contract_address};
use super::helper::deploy_upgradable;

#[starknet::contract]
mod TestContract {
    #[storage]
    struct Storage {}
}

mod UpgradeClass {
    use super::{
        TestContract, ClassHash, UpgradableComponent, pop_log_raw, deploy_upgradable, class_hash_const, set_contract_address,
        contract_address_const, IUpgradableDispatcherTrait
    };

    #[test]
    fn should_upgrade_class() {
        // Given
        let mut upgradable = deploy_upgradable();
        let new_class: ClassHash = TestContract::TEST_CLASS_HASH.try_into().unwrap();
        set_contract_address(contract_address_const::<'OWNER'>());

        // When
        upgradable.upgrade_class(new_class);

        // Then
        let expected_event = UpgradableComponent::Upgraded { class_hash: new_class };
        let (mut keys, mut data) = pop_log_raw(upgradable.contract_address).unwrap();
        let event: UpgradableComponent::Upgraded = starknet::Event::deserialize(ref keys, ref data).unwrap();
        assert(event == expected_event, 'invalid class hash');
    }

    #[test]
    #[should_panic(expected: ('CLASS_HASH_NOT_FOUND', 'ENTRYPOINT_FAILED'))]
    fn should_fail_when_class_does_not_exist() {
        // Given
        let mut upgradable = deploy_upgradable();
        let new_class = class_hash_const::<0x1234>();
        set_contract_address(contract_address_const::<'OWNER'>());

        // When & Then
        upgradable.upgrade_class(new_class);
    }

    #[test]
    #[should_panic(expected: ('Class hash cannot be zero', 'ENTRYPOINT_FAILED'))]
    fn should_fail_when_new_class_hash_is_zero() {
        // Given
        let mut upgradable = deploy_upgradable();
        let new_class = class_hash_const::<0x0>();
        set_contract_address(contract_address_const::<'OWNER'>());

        // When & Then
        upgradable.upgrade_class(new_class);
    }

    #[test]
    #[should_panic(expected: ('Caller is not the owner', 'ENTRYPOINT_FAILED'))]
    fn should_fail_when_caller_is_not_the_owner() {
        // Given
        let mut upgradable = deploy_upgradable();
        let new_class = class_hash_const::<0x3456>();
        set_contract_address(contract_address_const::<'NOT_OWNER'>());

        // When & Then
        upgradable.upgrade_class(new_class);
    }
}
