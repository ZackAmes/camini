use camini::pieces::pieces::IPieceDispatcher;
use starknet::ContractAddress;

#[dojo::interface]
trait IGov {
    fn add_piece(ref world: IWorldDispatcher, address: ContractAddress);
    fn add_effect(ref world: IWorldDispatcher, address: ContractAddress);
    fn set_damage_contract(ref world: IWorldDispatcher, address: ContractAddress);
}

#[dojo::contract]
mod gov {
    use super::IGov;
    use camini::models::{pool::{Pool}, piece::PieceType, position::{Vec2}, global::Global};
    use camini::consts::consts::POOL_ID;
    use camini::pieces::pieces::{IPieceDispatcher, IPiece, IPieceDispatcherTrait};
    use camini::effects::effects::{IEffectDispatcher, IEffect, IEffectDispatcherTrait};
    use camini::effects::models::Effect;

    use starknet::{ContractAddress, get_caller_address};

    #[abi(embed_v0)]
    impl GovImpl of IGov<ContractState> {

        fn add_piece (ref world: IWorldDispatcher, address: ContractAddress) {
            let creator = get_caller_address();

            let mut pool = get!(world, POOL_ID, (Pool));

            let mut pieces = pool.piece_type_ids;

            let mut index =0;
            
            let piece_dispatcher = IPieceDispatcher { contract_address: address};

            //todo check rest of endpoints
            let moves: Array<Vec2> = piece_dispatcher.get_move_pattern();

            assert!(moves.len() > 0, "invalid implementation");

            while index < pieces.len() {
                let id = *pieces.at(index);
                let checking_piece_type = get!(world, id, PieceType);

                assert!(address != checking_piece_type.contract, "Piece Type already added");

                index+=1;
                
            };

            let piece_type_id = world.uuid();
            let piece_type = PieceType { piece_type_id, creator, contract: address};

            pieces.append(piece_type_id);
            pool.piece_type_ids = pieces;

            set!(world, (pool, piece_type));

        }

        fn set_damage_contract(ref world: IWorldDispatcher, address: ContractAddress) {
            let mut global = get!(world, 0, (Global));

            assert!(global.damage_contract == starknet::contract_address_const::<0x0>(), "Already set");
            
            global.damage_contract = address;

            set!(world, (global));

        }

        fn add_effect (ref world: IWorldDispatcher, address: ContractAddress) {
            let mut pool = get!(world, POOL_ID, (Pool));

            let mut effects = pool.effect_type_ids;

            let mut index =0;
            
            let effect_dispatcher = IEffectDispatcher { contract_address: address};

            let test = effect_dispatcher.apply(0);


            assert!(test, "invalid implementation");

            while index < effects.len() {
                let id = *effects.at(index);
                let checking_effect_type = get!(world, id, PieceType);

                assert!(address != checking_effect_type.contract, "Effect already added");

                index+=1;
                
            };

            let effect_type_id = world.uuid();
            let effect_type = Effect { effect_id: effect_type_id, contract: address };

            effects.append(effect_type_id);
            pool.effect_type_ids = effects;

            set!(world, (pool, effect_type));

        }
    }
}