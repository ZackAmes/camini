use starknet::ContractAddress;
use camini::models::position::Vec2;

#[dojo::interface]
trait IPiece{
    fn get_moves() -> Array<Vec2>;
}


