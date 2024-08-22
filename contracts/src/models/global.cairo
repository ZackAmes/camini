use starknet::ContractAddress;

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Global {
    #[key]
    pub global_key: u8,
    pub pending_games: Array<u32>,
    pub damage_contract: ContractAddress
}