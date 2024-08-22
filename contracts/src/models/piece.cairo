use starknet::ContractAddress;
use camini::types::Location;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Piece {
    #[key]
    piece_id: u32,
    owner: ContractAddress,
    piece_type: u32,
    location: Location,
    data: PieceData
}

#[generate_trait]
impl pieceImpl of PieceTrait {
    fn new(piece_id: u32, owner: ContractAddress, piece_type:u32, base_health: u32) -> Piece{
        Piece {piece_id, owner, piece_type, location: Location::Owner, data: PieceData {health: base_health} }
    }
}

#[derive(Copy, Drop, Serde, Introspect)]
pub struct PieceData {
    health: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct PieceType {
    #[key]
    piece_type_id: u32,
    creator: ContractAddress,
    contract: ContractAddress
}
