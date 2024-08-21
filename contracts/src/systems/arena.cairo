// define the interface
use camini::types::Vec2;

#[dojo::interface]
trait IArena {
   fn move(ref world: IWorldDispatcher, game_id: u32, piece_id: u32, to: Vec2);
}

// dojo decorator
#[dojo::contract]
mod arena {
    use super::{IArena};
    use starknet::{ContractAddress, get_caller_address};
    use camini::models::{position::{Position, Tile}, piece::{Piece, PieceType}};
    use camini::pieces::pieces::{IPieceDispatcher, IPieceDispatcherTrait};
    use camini::types::{Vec2, Location};


    #[abi(embed_v0)]
    impl arenaImpl of IArena<ContractState> {
        
        fn move(ref world: IWorldDispatcher, game_id: u32, piece_id: u32, to: Vec2) {

            let player = get_caller_address();
            let piece = get!(world, piece_id, (Piece));
            let piece_type = get!(world, piece.piece_type, (PieceType));

            let moves = (IPieceDispatcher { contract_address: piece_type.contract}).get_moves();

            let mut position = get!(world, (game_id, piece_id), (Position));
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

        }

    }
}

