
#[derive(Copy, Drop, Serde, Introspect, PartialEq)]
pub enum Location {
    Owner,
    Team :u32,
    Game: u32,
    Graveyard
} 


#[derive(Copy, Drop, Serde, Introspect, PartialEq)]
pub struct Vec2 {
    pub x: i8,
    pub y: i8
}
