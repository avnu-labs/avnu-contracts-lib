use avnu_lib::components::whitelist::IWhitelistDispatcherTrait;
use starknet::contract_address_const;
use starknet::testing::set_contract_address;
use super::helper::deploy_whitelist;

mod IsWhitelisted {
    use super::{deploy_whitelist, IWhitelistDispatcherTrait, contract_address_const};

    #[test]
    fn should_return_a_bool() {
        // Given
        let whitelist = deploy_whitelist();
        let address = contract_address_const::<'CALLER'>();

        // When
        let result = whitelist.is_whitelisted(address);

        // Then
        assert(result == false, 'invalid is_whitelisted');
    }
}

mod SetWhitelistedCaller {
    use super::{deploy_whitelist, IWhitelistDispatcherTrait, contract_address_const, set_contract_address};

    #[test]
    fn should_set_whitelisted_addresses() {
        // Given
        let whitelist = deploy_whitelist();
        let address = contract_address_const::<'CALLER'>();
        set_contract_address(contract_address_const::<'OWNER'>());

        // When
        let result = whitelist.set_whitelisted_address(address, true);

        // Then
        assert(result == true, 'invalid result');
        let fees_active = whitelist.is_whitelisted(address);
        assert(fees_active == true, 'invalid fees_active');
    }

    #[test]
    #[should_panic(expected: ('Caller is not the owner', 'ENTRYPOINT_FAILED'))]
    fn should_fail_when_caller_is_not_the_owner() {
        // Given
        let whitelist = deploy_whitelist();
        let address = contract_address_const::<'CALLER'>();
        set_contract_address(contract_address_const::<'NOT_OWNER'>());

        // When & Then
        whitelist.set_whitelisted_address(address, true);
    }
}
