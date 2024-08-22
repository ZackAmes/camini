

#[dojo::interface]
trait IGacha {
    fn mint(ref world: IWorldDispatcher) -> u32;
}

#[dojo::contract]
mod gacha {

    use super::IGacha;
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use origami_random::dice::{Dice, DiceTrait};
    use camini::models::pool::{Pool};
    use camini::models::piece::{Piece, PieceTrait, PieceType};
    use camini::models::player::{Player};
    use camini::consts::consts::{POOL_ID};
    use camini::pieces::pieces::{IPieceDispatcher, IPieceDispatcherTrait};
    use camini::types::Location;

    #[abi(embed_v0)]
    impl gachaImpl of IGacha<ContractState> {

        fn mint(ref world: IWorldDispatcher) -> u32 {
            let owner = get_caller_address();
            let pool = get!(world, POOL_ID, (Pool));
            
            let mut player = get!(world, owner, (Player));

            let piece_id = world.uuid();

            let mut dice = DiceTrait::new(pool.piece_type_ids.len().try_into().unwrap(), get_block_timestamp().into());
            let piece_type_id: u32 = dice.roll().into();

            let piece_type = get!(world, piece_type_id, (PieceType));
            let piece_type_dispatcher = IPieceDispatcher {contract_address: piece_type.contract} ;

            let base_health = piece_type_dispatcher.get_base_health();
            let piece = PieceTrait::new(piece_id, owner, piece_type_id, base_health);
            player.pieces.append(piece_id);

            set!(world, (player, piece));

            piece_id
        }
    }



}