#[cfg(test)]
mod tests {
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::utils::test::{spawn_test_world, deploy_contract};
    // import test utils
    use camini::{
        systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait},
                gov::{gov, IGovDispatcher, IGovDispatcherTrait},
                matchmaking::{matchmaking, IMatchmakingDispatcher, IMatchmakingDispatcherTrait},
                gacha::{gacha, IGachaDispatcher, IGachaDispatcherTrait}
                
            },
        models::{game::{Game, game}, 
                position::{Position, Vec2, position},
                global::{Global, global},
                player::{Player, player},
                pool::{Pool, pool}, 
                piece::{Piece, PieceType, piece, piece_type},
            },
        pieces::{pieces::{IPieceDispatcher, IPieceDispatcherTrait}, a::{a}, b::{b}},
        consts::consts::{POOL_ID}
    };

    fn setup() -> (IWorldDispatcher, 
                    IActionsDispatcher, 
                    IMatchmakingDispatcher, 
                    IGovDispatcher, 
                    IGachaDispatcher) {

        let caller = starknet::contract_address_const::<0x0>();

        // models
        let mut models = array![position::TEST_CLASS_HASH, 
                                game::TEST_CLASS_HASH,
                                global::TEST_CLASS_HASH,
                                player::TEST_CLASS_HASH,
                                pool::TEST_CLASS_HASH,
                                piece::TEST_CLASS_HASH,
                                piece_type::TEST_CLASS_HASH];

        // deploy world with models
        let world = spawn_test_world(["ok"].span(), models.span());

        // deploy systems contract
        let actions_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let matchmaking_address = world
            .deploy_contract('m', matchmaking::TEST_CLASS_HASH.try_into().unwrap());
        let gov_address = world
            .deploy_contract('gov', gov::TEST_CLASS_HASH.try_into().unwrap());
        let gacha_address = world
            .deploy_contract('gacha', gacha::TEST_CLASS_HASH.try_into().unwrap());
        
        let actions_system = IActionsDispatcher { contract_address: actions_address };
        let matchmaking_system = IMatchmakingDispatcher { contract_address: matchmaking_address };
        let gov_system = IGovDispatcher { contract_address: gov_address };
        let gacha_system = IGachaDispatcher {contract_address: gacha_address};


        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), actions_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), matchmaking_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), gov_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), gacha_address);

        (world, actions_system, matchmaking_system, gov_system, gacha_system)
    }

    #[test]
    fn test_add_type() {
        // caller
        let caller = starknet::contract_address_const::<0x0>();

        let (world, actions, matchmaking, gov, gacha) = setup();

        let a_address = world
            .deploy_contract('a', a::TEST_CLASS_HASH.try_into().unwrap());
        let b_address = world
            .deploy_contract('b', b::TEST_CLASS_HASH.try_into().unwrap());

        gov.add_piece(a_address);
        gov.add_piece(b_address);

        let pool = get!(world, POOL_ID, (Pool));

        assert!(pool.piece_type_ids.len() == 2, "piece types not added");

    }

    #[test]
    fn test_mint() {
        // caller
        let caller = starknet::contract_address_const::<0x0>();

        let (world, actions, matchmaking, gov, gacha) = setup();

        let a_address = world
            .deploy_contract('a', a::TEST_CLASS_HASH.try_into().unwrap());
        let b_address = world
            .deploy_contract('b', b::TEST_CLASS_HASH.try_into().unwrap());

        gov.add_piece(a_address);
        gov.add_piece(b_address);

        let piece_id = gacha.mint();

        let piece = get!(world, piece_id, (Piece));

        assert!(piece.owner == caller, "piece not minted");

    }


}
