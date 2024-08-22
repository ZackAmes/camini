#[dojo::contract]
mod b{

    use camini::pieces::pieces::IPiece;
    use camini::models::position::Vec2;


    #[abi(embed_v0)]
    impl BImpl of IPiece<ContractState> {

        fn get_move_pattern() -> Array<Vec2>{
            let res = array![Vec2{x:1, y:1}];
            res
        }

        fn get_attack_pattern() -> Array<Vec2>{
            let res = array![Vec2 {x:0, y:1}];
            res
        }

        fn get_attack() -> u32 {
            50
        }

        fn get_base_health() -> u32 {
            750
        }

        //todo
        fn get_ability_effect() -> u32 {
            0
        }

        fn get_ability_pattern() -> Array<Vec2>{
            array![Vec2 {x: 1, y: 1}, Vec2 {x:-1, y:1} ]
        }
    }


}