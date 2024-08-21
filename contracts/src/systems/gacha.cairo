

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
    use camini::models::piece::{Piece};
    use camini::models::player::{Player};
    use camini::consts::consts::{POOL_ID};


    #[abi(embed_v0)]
    impl gachaImpl of IGacha<ContractState> {

        fn mint(ref world: IWorldDispatcher) -> u32 {
            let owner = get_caller_address();
            let pool = get!(world, POOL_ID, (Pool));
            
            let mut player = get!(world, owner, (Player));

            let piece_id = world.uuid();

            let mut dice = DiceTrait::new(pool.piece_type_ids.len().try_into().unwrap(), get_block_timestamp().into());
            let piece_type: u32 = dice.roll().into();

            let piece = Piece { piece_id, owner, piece_type};
            player.pieces.append(piece_id);

            set!(world, (player, piece));

            piece_id

        }


    }



}