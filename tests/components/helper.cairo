use avnu_lib::components::ownable::IOwnableDispatcher;
use avnu_lib::components::upgradable::IUpgradableDispatcher;
use avnu_lib::components::whitelist::IWhitelistDispatcher;
use starknet::syscalls::deploy_syscall;
use starknet::testing::pop_log_raw;
use super::mocks::ownable_mock::OwnableMock;
use super::mocks::upgradable_mock::UpgradableMock;
use super::mocks::whitelist_mock::WhitelistMock;


pub fn deploy_ownable() -> IOwnableDispatcher {
    let mut calldata = array!['OWNER'];
    let (address, _) = deploy_syscall(OwnableMock::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false)
        .expect('Failed to deploy OwnableMock');
    pop_log_raw(address).unwrap();
    IOwnableDispatcher { contract_address: address }
}

pub fn deploy_upgradable() -> IUpgradableDispatcher {
    let mut calldata = array!['OWNER'];
    let (address, _) = deploy_syscall(UpgradableMock::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false)
        .expect('Failed to deploy UpgradableMock');
    pop_log_raw(address).unwrap();
    IUpgradableDispatcher { contract_address: address }
}

pub fn deploy_whitelist() -> IWhitelistDispatcher {
    let mut calldata = array!['OWNER'];
    let (address, _) = deploy_syscall(WhitelistMock::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false)
        .expect('Failed to deploy WhitelistMock');
    pop_log_raw(address).unwrap();
    IWhitelistDispatcher { contract_address: address }
}
