use starknet::ContractAddress;

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Player {
    #[key]
    pub address: ContractAddress,
    pub games: Array<u32>,
    pub pieces: Array<u32>
}

