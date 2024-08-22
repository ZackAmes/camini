use starknet::ContractAddress;
use camini::models::position::Vec2;

#[dojo::interface]
trait IPiece{
    fn get_move_pattern() -> Array<Vec2>;
    fn get_attack_pattern() -> Array<Vec2>;
    fn get_attack() -> u32;
    fn get_base_health() -> u32;
    
    //potentially make array to compose effects?
    fn get_ability_effect() -> u32;
    fn get_ability_pattern() -> Array<Vec2>;

}


