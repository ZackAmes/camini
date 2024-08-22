#[starknet::component]
mod PieceComponent {

    // Starknet imports

    use starknet::ContractAddress;
    use starknet::info::get_caller_address;
    use starknet::storage::Map as StorageMap;

    // Dojo imports

    use dojo::world::IWorldDispatcher;
    use dojo::world::IWorldDispatcherTrait;

    use camini::types::Vec2;


    // Errors

    mod errors {}

    // Storage

    #[storage]
    struct Storage {
    }

    // Events

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn get_move_pattern(
            self: @ComponentState<TContractState>) -> Span<Vec2> {
            
        }



    }
}