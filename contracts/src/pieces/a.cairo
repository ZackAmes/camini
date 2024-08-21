#[dojo::contract]
mod A{

    use super::IPiece;

    #[abi(embed_v0)]
    impl PieceImpl of IPiece<ContractState> {

        fn get_moves() -> {
            let res = array![Vec2{x:1, y:1}];
            res
        }

        

    }

}


