// define the interface
#[dojo::interface]
trait IArena {
   // fn move(ref world: IWorldDispatcher);
}

// dojo decorator
#[dojo::contract]
mod arena {
    use super::{IArena};
    use starknet::{ContractAddress, get_caller_address};
    use camini::models::position::{Position, Vec2};

    #[abi(embed_v0)]
    impl arenaImpl of IArena<ContractState> {
        

    }
}

