use avnu_lib::components::pausable::{IPausableDispatcherTrait, PausableComponent};
use starknet::class_hash::{class_hash_const, ClassHash};
use starknet::contract_address_const;
use starknet::testing::{pop_log_raw, set_contract_address};
use super::helper::deploy_pausable;

mod IsPaused {
    use super::{PausableComponent, deploy_pausable, IPausableDispatcherTrait};

    #[test]
    fn should_return_paused_value() {
        // Given
        let mut pausable = deploy_pausable();

        // When
        let paused = pausable.is_paused();

        // Then
        assert(paused == false, 'invalid paused value');
    }
}

mod Pause {
    use super::{PausableComponent, pop_log_raw, deploy_pausable, set_contract_address, contract_address_const, IPausableDispatcherTrait};

    #[test]
    fn should_pause_the_component() {
        // Given
        let mut pausable = deploy_pausable();
        set_contract_address(contract_address_const::<'OWNER'>());

        // When
        pausable.pause();

        // Then
        let paused = pausable.is_paused();
        assert(paused == true, 'invalid paused value');
        let expected_event = PausableComponent::Paused {};
        let (mut keys, mut data) = pop_log_raw(pausable.contract_address).unwrap();
        let event: PausableComponent::Paused = starknet::Event::deserialize(ref keys, ref data).unwrap();
        assert(event == expected_event, 'invalid event');
    }

    #[test]
    #[should_panic(expected: ('Pausable: paused', 'ENTRYPOINT_FAILED'))]
    fn should_fail_when_already_paused() {
        // Given
        let mut pausable = deploy_pausable();
        set_contract_address(contract_address_const::<'OWNER'>());
        pausable.pause();

        // When & Then
        pausable.pause();
    }

    #[test]
    #[should_panic(expected: ('Caller is not the owner', 'ENTRYPOINT_FAILED'))]
    fn should_fail_when_caller_is_not_the_owner() {
        // Given
        let mut pausable = deploy_pausable();
        set_contract_address(contract_address_const::<'NOT_OWNER'>());

        // When & Then
        pausable.pause();
    }
}

mod UnPause {
    use super::{PausableComponent, pop_log_raw, deploy_pausable, set_contract_address, contract_address_const, IPausableDispatcherTrait};

    #[test]
    fn should_unpause_the_component() {
        // Given
        let mut pausable = deploy_pausable();
        set_contract_address(contract_address_const::<'OWNER'>());
        pausable.pause();
        pop_log_raw(pausable.contract_address).unwrap();

        // When
        pausable.unpause();

        // Then
        let paused = pausable.is_paused();
        assert(paused == false, 'invalid paused value');
        let expected_event = PausableComponent::Unpaused {};
        let (mut keys, mut data) = pop_log_raw(pausable.contract_address).unwrap();
        let event: PausableComponent::Unpaused = starknet::Event::deserialize(ref keys, ref data).unwrap();
        assert(event == expected_event, 'invalid event');
    }

    #[test]
    #[should_panic(expected: ('Pausable: not paused', 'ENTRYPOINT_FAILED'))]
    fn should_fail_when_not_paused() {
        // Given
        let mut pausable = deploy_pausable();
        set_contract_address(contract_address_const::<'OWNER'>());

        // When & Then
        pausable.unpause();
    }

    #[test]
    #[should_panic(expected: ('Caller is not the owner', 'ENTRYPOINT_FAILED'))]
    fn should_fail_when_caller_is_not_the_owner() {
        // Given
        let mut pausable = deploy_pausable();
        set_contract_address(contract_address_const::<'NOT_OWNER'>());

        // When & Then
        pausable.unpause();
    }
}
