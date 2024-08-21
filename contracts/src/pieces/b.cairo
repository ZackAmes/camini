#[dojo::contract]
mod B{

    use camini::pieces::pieces::IPiece;

    #[abi(embed_v0)]
    impl BImpl of IPiece<ContractState> {

        fn get_moves() -> {
            let res = array![Vec2{x:1, y:1}];
            res
        }

    }


}