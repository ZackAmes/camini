use camini::types::Location;
use starknet::ContractAddress;

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Team {
    #[key]
    team_id: u32,
    owner: ContractAddress,
    pieces: Array<u32>,
    location: Location
}