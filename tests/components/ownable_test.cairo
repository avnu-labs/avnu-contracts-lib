use avnu_lib::components::ownable::IOwnableDispatcherTrait;
use starknet::contract_address_const;
use starknet::testing::set_contract_address;
use super::helper::deploy_ownable;

mod GetOwner {
    use super::{deploy_ownable, contract_address_const, IOwnableDispatcherTrait};

    #[test]
    fn should_return_owner() {
        // Given
        let owner = deploy_ownable();
        let expected = contract_address_const::<'OWNER'>();

        // When
        let result = owner.get_owner();

        // Then
        assert(result == expected, 'invalid owner');
    }
}

mod TransferOwnership {
    use super::{deploy_ownable, contract_address_const, IOwnableDispatcherTrait, set_contract_address};

    #[test]
    fn should_change_owner() {
        // Given
        let mut owner = deploy_ownable();
        let new_owner = contract_address_const::<'NEW_OWNER'>();
        set_contract_address(contract_address_const::<'OWNER'>());

        // When
        owner.transfer_ownership(new_owner);

        // Then
        let owner = owner.get_owner();
        assert(owner == new_owner, 'invalid owner');
    }

    #[test]
    #[should_panic(expected: ('Caller is not the owner', 'ENTRYPOINT_FAILED'))]
    fn should_fail_when_caller_is_not_the_owner() {
        // Given
        let mut owner = deploy_ownable();
        let new_owner = contract_address_const::<'NEW_OWNER'>();
        set_contract_address(contract_address_const::<'NOT_OWNER'>());

        // When & Then
        owner.transfer_ownership(new_owner);
    }

    #[test]
    #[should_panic(expected: ('New owner is the zero address', 'ENTRYPOINT_FAILED'))]
    fn should_fail_when_owner_is_0() {
        // Given
        let mut owner = deploy_ownable();
        let new_owner = contract_address_const::<0x0>();
        set_contract_address(owner.get_owner());

        // When & Then
        owner.transfer_ownership(new_owner);
    }
}
