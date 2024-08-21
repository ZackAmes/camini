// define the interface
#[dojo::interface]
trait IActions {
   // fn move(ref world: IWorldDispatcher);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address};
    use camini::models::position::{Position, Vec2};

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        

    }
}

