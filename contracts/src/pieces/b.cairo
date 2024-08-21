#[dojo::contract]
mod b{

    use camini::pieces::pieces::IPiece;
    use camini::models::position::Vec2;


    #[abi(embed_v0)]
    impl BImpl of IPiece<ContractState> {

        fn get_moves() -> Array<Vec2>{
            let res = array![Vec2{x:-1, y:-1}];
            res
        }

    }


}