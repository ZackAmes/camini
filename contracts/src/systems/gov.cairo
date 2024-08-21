use camini::pieces::pieces::IPieceDispatcher;
use starknet::ContractAddress;

#[dojo::interface]
trait IGov {
    fn add_piece(ref world: IWorldDispatcher, address: ContractAddress);
}

#[dojo::contract]
mod Gov {
    use super::IGov;
    use camini::models::{pool::{Pool}, piece::PieceType, position::{Vec2}};
    use camini::consts::consts::POOL_ID;
    use camini::pieces::pieces::{IPieceDispatcher, IPiece, IPieceDispatcherTrait};

    use starknet::{ContractAddress, get_caller_address};

    #[abi(embed_v0)]
    impl GovImpl of IGov<ContractState> {

        fn add_piece (ref world: IWorldDispatcher, address: ContractAddress) {
            let creator = get_caller_address();

            let mut pool = get!(world, POOL_ID, (Pool));

            let mut pieces = pool.piece_type_ids;

            let mut index =0;
            
            let piece_dispatcher = IPieceDispatcher { contract_address: address};

            let moves: Array<Vec2> = piece_dispatcher.get_moves();

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
    }
}