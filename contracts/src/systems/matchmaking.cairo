// define the interface
#[dojo::interface]
trait IMatchmaking {
    fn create_game(ref world: IWorldDispatcher) -> u32;
    fn join_game(ref world: IWorldDispatcher, game_id:u32);
    fn start_game(ref world: IWorldDispatcher, game_id: u32);
 //   fn pending_games(ref world: IWorldDispatcher) -> Array<u32>;
}

#[dojo::contract]
mod matchmaking {

    use super::{IMatchmaking};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use camini::models::{
        position::{Position}, game::{Game, Status, TurnPhase}, player::{Player}, global::{Global}
    };

    #[abi(embed_v0)]
    impl matchmakingImpl of IMatchmaking<ContractState> {
        fn create_game(ref world: IWorldDispatcher) -> u32 {
            let address = get_caller_address();
            let game_id = world.uuid();
            let players = array![address];
            let status = Status::Pending;
            let phase = TurnPhase::Standby;

            let mut player = get!(world, address, (Player));
            let mut global = get!(world, 0, (Global));

            player.games.append(game_id);
            global.pending_games.append(game_id);

            let game = Game {game_id, players, turn_player:address, status, phase};
            
            set!(world, (global, game, player));

            game_id
        }

        fn join_game(ref world: IWorldDispatcher, game_id: u32) {
            let address = get_caller_address();

            let mut game = get!(world, game_id, (Game));
            assert!(game.status == Status::Pending, "Game not joinable");

            assert!(game.players.len() == 1, "game full");

            let mut player = get!(world, address, (Player));
            player.games.append(game_id);
            
            set!(world, (game, player));

        }

        fn start_game(ref world: IWorldDispatcher, game_id: u32) {

            let player = get_caller_address();
            let mut game = get!(world, game_id, Game);

            assert!(game.status == Status::Pending, "Game already started");
            
            assert!(game.turn_player == player, "Not lobby creator");
            
            let mut global = get!(world, 0, (Global));

            let mut updated_games = array![];

            let mut index = 0;

            loop {

                let to_check = *global.pending_games.at(index);

                if to_check != game_id {
                    updated_games.append(to_check);                
                }

                index += 1;
                if index >= global.pending_games.len() {
                    break;
                }
            };

            global.pending_games = updated_games;           
            game.status = Status::Active;

            set!(world, (game, global));


        }
    }
}