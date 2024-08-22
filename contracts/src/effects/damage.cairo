use camini::effects::effects::IEffect;

#[dojo::interface]
trait IDamage {
    fn set_amt(ref world: IWorldDispatcher, amt: u32);
}

#[dojo::contract]
mod damage {

    use starknet::{get_caller_address, ContractAddress};
    use super::IDamage;
    use camini::effects::effects::IEffect;
    use camini::effects::models::{DamageAmt};
    use camini::models::{position::Position, piece::Piece};
    use camini::types::Location;

    #[abi(embed_v0)]
    impl damageImpl of IDamage<ContractState> {
        fn set_amt(ref world: IWorldDispatcher, amt: u32) {
            let caller = get_caller_address();
            let dmg = DamageAmt {creator: caller, amt}; 
            set!( world, (dmg));
        }
    }

    #[abi(embed_v0)]
    impl damageEffectImpl of IEffect<ContractState> {

        fn apply(ref world: IWorldDispatcher, target: u32) -> bool{
            let caller = get_caller_address();
            let dmg = get!(world, caller, (DamageAmt)).amt;
            let mut target = get!(world, target, (Piece));

            if target.data.health > dmg {
                target.data.health - dmg;
            }
            else {
                target.data.health = 0;
                target.location = Location::Graveyard;
            }

            set!(world, (target));
            true


        }
    }


}