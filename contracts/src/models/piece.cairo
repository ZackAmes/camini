use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Piece {
    #[key]
    piece_id: u32,
    owner: ContractAddress,
    piece_type: u32
}


#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct PieceType {
    #[key]
    piece_type_id: u32,
    creator: ContractAddress,
    contract: ContractAddress
}
