// define the interface
use camini::types::Vec2;

#[dojo::interface]
trait IArena {
   fn move(ref world: IWorldDispatcher, game_id: u32, piece_id: u32, to: Vec2);
   fn attack(ref world: IWorldDispatcher, game_id: u32, piece_id: u32, target: Vec2);
}

// dojo decorator
#[dojo::contract]
mod arena {
    use super::{IArena};
    use starknet::{ContractAddress, get_caller_address};
    use camini::models::{position::{Position, Tile}, piece::{Piece, PieceType}, global::Global};
    use camini::pieces::pieces::{IPieceDispatcher, IPieceDispatcherTrait};
    use camini::types::{Vec2, Location};
    use camini::effects::{effects::{IEffectDispatcher, IEffectDispatcherTrait},
                        damage::{IDamageDispatcher, IDamageDispatcherTrait}};


    #[abi(embed_v0)]
    impl arenaImpl of IArena<ContractState> {
        
        fn move(ref world: IWorldDispatcher, game_id: u32, piece_id: u32, to: Vec2) {

            let player = get_caller_address();
            let piece = get!(world, piece_id, (Piece));
            let piece_type = get!(world, piece.piece_type, (PieceType));

            let moves = (IPieceDispatcher { contract_address: piece_type.contract}).get_move_pattern();

            let mut position = get!(world, piece_id, (Position));
            let mut start_tile = get!(world, (game_id, position.position), (Tile));
            let mut end_tile = get!(world, (game_id, to), (Tile));
            
            assert!(end_tile.piece == 0, "tile is occupied");

            
            let mut i = 0;
            let mut valid = false;
            
            while (i < moves.len() && !valid) {
                let move = *moves.at(i);
                valid = (position.position.x + move.x == to.x && position.position.y + move.y == to.y);
                i+=1;

            };
        
            assert!(valid, "Invalid move");
            position.position = to;
            start_tile.piece = 0;
            end_tile = Tile { game_id, position: to, piece: piece_id};
            
            set!(world, (position, start_tile, end_tile)); 
            //TODO change turn player

        }

        fn attack(ref world: IWorldDispatcher, game_id: u32, piece_id: u32, target: Vec2) {

            let player = get_caller_address();
            let piece = get!(world, piece_id, (Piece));
            let piece_type = get!(world, piece.piece_type, (PieceType));

            let piece_dispatcher = (IPieceDispatcher { contract_address: piece_type.contract});
            let attacks = piece_dispatcher.get_attack_pattern();
            let power = piece_dispatcher.get_attack();

            let mut position = get!(world, piece_id, (Position));
            let mut end_tile = get!(world, (game_id, target), (Tile));
            
            assert!(end_tile.piece != 0, "tile is empty");
            
            let mut i = 0;
            let mut valid = false;
            
            while (i < attacks.len() && !valid) {
                let attack = *attacks.at(i);
                valid = (position.position.x + attack.x == target.x && position.position.y + attack.y == target.y);
                i+=1;
            };
        
            assert!(valid, "Invalid attack");

            let damage_address = get!(world, 0, (Global)).damage_contract;
            let damage_dispatcher = IDamageDispatcher {contract_address: damage_address };
            let damage_effect_dispatcher = IEffectDispatcher {contract_address: damage_address};

            damage_dispatcher.set_amt(power);
            damage_effect_dispatcher.apply(end_tile.piece);
            
            //TODO change turn player

        }

    }
}

