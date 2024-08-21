use camini::pieces::pieces::IPieceDispatcher;

#[dojo::interface]
trait IGov {
    fn add_piece(contract: IPieceDispatcher);
}

#[dojo::contract]
mod Gov {
    use super::IGov;
    use camini::models::{pool::Pool, piece::PieceType};
    use camini::consts::consts::POOL_ID;
    use starknet::get_caller_address;

    #[abi(embed_v0)]
    impl GovImpl of IGov<ContractState> {

        fn add_piece (contract: IPieceDispatcher) {
            let creator = get_caller_address();

            let mut pool = get!(world, POOL_ID, (Pool));

            let mut pieces = pool.piece_type_ids;

            let mut index =0;

            while index < pieces.len() {
                let id = *pieces.at(index);
                let checking_piece_type = get!(world, id, PieceType);

                assert!(contract.address != piece_type.contract.address, "Piece Type already added");

                index+=1;
                
            };

            let piece_type_id = world.uuid();
            let piece_type = PieceType { piece_type_id, creator, contract};

            pieces.append(piece_type_id);
            pool.piece_type_ids = pieces;

            set!(world, (pool, piece_type));

        }
    }
}