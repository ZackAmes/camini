// define the interface
#[dojo::interface]
trait IMatchmaking {
    fn create_game(ref world: IWorldDispatcher, team_id: u32) -> u32;
    fn join_game(ref world: IWorldDispatcher, game_id:u32, team_id: u32);
    fn start_game(ref world: IWorldDispatcher, game_id: u32);
 //   fn pending_games(ref world: IWorldDispatcher) -> Array<u32>;
}

#[dojo::contract]
mod matchmaking {

    use super::{IMatchmaking};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use camini::models::{
        position::{Position, Tile}, 
        game::{Game, Status, TurnPhase}, 
        player::{Player}, 
        global::{Global}, 
        team::{Team},
        piece::{Piece}
    };
 
    use camini::types::{Location, Vec2};

    #[abi(embed_v0)]
    impl matchmakingImpl of IMatchmaking<ContractState> {
        fn create_game(ref world: IWorldDispatcher, team_id: u32) -> u32 {
            let address = get_caller_address();
            let game_id = world.uuid();
            let players = array![address];
            let teams = array![team_id];
            let status = Status::Pending;
            let phase = TurnPhase::Standby;

            let mut team = get!(world, team_id, (Team));
            assert!(team.pieces.len() > 0, "Team has no pieces");
            assert!(team.location == Location::Owner, "team not available");
            assert!(team.owner == address, "not team owner");

            let mut player = get!(world, address, (Player));
            let mut global = get!(world, 0, (Global));

            team.location = Location::Game(game_id);

            player.games.append(game_id);
            global.pending_games.append(game_id);

            let game = Game {game_id, players, turn_player:address,teams, status, phase};
            
            set!(world, (global, game, player, team));

            game_id
        }

        fn join_game(ref world: IWorldDispatcher, game_id: u32, team_id: u32) {
            let address = get_caller_address();

            let mut game = get!(world, game_id, (Game));
            let mut team = get!(world, team_id, (Team));

            assert!(game.status == Status::Pending, "Game not joinable");
            assert!(game.players.len() == 1, "game full");
            assert!(team.pieces.len() > 0, "Team has no pieces");
            assert!(team.location == Location::Owner, "team not available");
            assert!(team.owner == address, "not team owner");

            team.location = Location::Game(game_id);

            let mut player = get!(world, address, (Player));
            player.games.append(game_id);
            
            set!(world, (team, game, player));

        }

        fn start_game(ref world: IWorldDispatcher, game_id: u32) {

            let player = get_caller_address();
            let mut game = get!(world, game_id, Game);

            assert!(game.status == Status::Pending, "Game already started");
            assert!(game.turn_player == player, "Not lobby creator");
            assert!(game.teams.len() == 2, "Need 2 players");
            
            let mut global = get!(world, 0, (Global));

            let mut updated_games = array![];

            let mut index = 0;

            while index < global.pending_games.len() {

                let to_check = *global.pending_games.at(index);

                if to_check != game_id {
                    updated_games.append(to_check);                
                }

                index += 1;
            };

            global.pending_games = updated_games;           
            game.status = Status::Active;
            self.update_pieces(world, game_id);

            set!(world, (game, global));

        }
    }


    #[generate_trait]
    impl Private of PrivateTrait {
        fn update_pieces(ref self: ContractState, world: IWorldDispatcher, game_id: u32)  {
            let game = get!(world, game_id, (Game));

            let mut i = 0;
            while i < game.teams.len() {
                let team_id = *game.teams.at(i);
                let team = get!(world, team_id, (Team));

                // assume 2 teams

                let mut j = 0;
                while j < team.pieces.len() {
                    let piece_id = *team.pieces.at(j);
                    let mut piece = get!(world, piece_id, (Piece));
                    piece.location = Location::Game(game_id);
                    //6x6 grid, 
                    let x: i8 = j.try_into().unwrap() + 1;
                    let mut y:i8 = 0;
                    if i == 1 {
                        y = 5;
                    }
                    let position = Position { piece_id, game_id, position: Vec2{ x, y }};
                    let tile = Tile { game_id, position: Vec2{ x, y }, piece: piece_id};
                    set!(world, (piece, position, tile));
                };
                i+=1;
            };
        }
    }
}