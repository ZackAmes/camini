use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Position {
    #[key]
    pub piece_id: u32,
    pub game_id: u32,
    pub position: Vec2,
}

#[derive(Copy, Drop, Serde, Introspect)]
pub struct Vec2 {
    pub x: i8,
    pub y: i8
}
