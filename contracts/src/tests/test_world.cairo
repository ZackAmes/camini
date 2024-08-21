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
                matchmaking::{matchmaking, IMatchmakingDispatcher, IMatchmakingDispatcherTrait}
                
            },
        models::{game::{Game, game}, 
                position::{Position, Vec2, position},
                global::{Global, global},
                player::{Player, player},
                pool::{Pool, pool}, 
                piece::{Piece, PieceType, piece, piece_type},
            },
        pieces::{pieces::{IPieceDispatcher, IPieceDispatcherTrait}, a::{a}, b::{b}},
        consts::{POOL_ID}
    };

    #[test]
    fn test_add_type() {
        // caller
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
            .deploy_contract('g', gov::TEST_CLASS_HASH.try_into().unwrap());
        
        let actions_system = IActionsDispatcher { contract_address: actions_address };
        let matchmaking_system = IMatchmakingDispatcher { contract_address: matchmaking_address };
        let gov_system = IGovDispatcher { contract_address: gov_address };

        let a_address = world
            .deploy_contract('a', a::TEST_CLASS_HASH.try_into().unwrap());
        let b_address = world
            .deploy_contract('b', b::TEST_CLASS_HASH.try_into().unwrap());

        let a_dispatcher = IPieceDispatcher { contract_address: a_address};
        let b_dispatcher = IPieceDispatcher { contract_address: b_address}; 

        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), actions_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), matchmaking_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), gov_address);

        gov_system.add_piece(a_dispatcher);
        gov_system.add_piece(b_dispatcher);

        let pool = get!(world, pool_id, (Pool));

        assert!(pool.piece_type_ids.len() == 2, "pieces types not added");


    }
}
