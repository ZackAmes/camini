use starknet::ContractAddress;
use camini::types::Vec2;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Position {
    #[key]
    pub piece_id: u32,
    pub game_id: u32,
    pub position: Vec2,
}
