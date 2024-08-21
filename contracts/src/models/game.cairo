use starknet::ContractAddress;

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    pub game_id: u32,
    pub players: Array<ContractAddress>,
    pub teams: Array<u32>,
    pub turn_player: ContractAddress,
    pub status: Status,
    pub phase: TurnPhase
}

#[derive(Copy, Drop, Serde, Introspect, PartialEq)]
pub enum Status {
    Pending, 
    Active,
    Completed
}

#[derive(Copy, Drop, Serde, Introspect, PartialEq)]
pub enum TurnPhase {
    Standby,
    Moving,
    End
}




