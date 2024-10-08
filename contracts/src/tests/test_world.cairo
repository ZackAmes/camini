#[cfg(test)]
mod tests {
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::utils::test::{spawn_test_world, deploy_contract};
    use starknet::testing::{set_caller_address};
    use starknet::ContractAddress;
    // import test utils
    use camini::{
        systems::{arena::{arena, IArenaDispatcher, IArenaDispatcherTrait},
                gov::{gov, IGovDispatcher, IGovDispatcherTrait},
                matchmaking::{matchmaking, IMatchmakingDispatcher, IMatchmakingDispatcherTrait},
                gacha::{gacha, IGachaDispatcher, IGachaDispatcherTrait},
                teambuilder::{teambuilder, ITeambuilderDispatcher, ITeambuilderDispatcherTrait}
                
            },
        models::{game::{Game, Status, game}, 
                position::{Position, Tile,tile, position},
                global::{Global, global},
                player::{Player, player},
                pool::{Pool, pool}, 
                piece::{Piece, PieceType, piece, piece_type},
                team::{Team, team}
            },
        pieces::{pieces::{IPieceDispatcher, IPieceDispatcherTrait}, a::{a}, b::{b}},
        types::{Location, Vec2},
        consts::consts::{POOL_ID}
    };

    fn setup() -> ( IWorldDispatcher, 
                    IArenaDispatcher, 
                    IMatchmakingDispatcher, 
                    IGovDispatcher, 
                    IGachaDispatcher,
                    ITeambuilderDispatcher) {

        let caller = starknet::contract_address_const::<0x0>();

        // models
        let mut models = array![position::TEST_CLASS_HASH, 
                                game::TEST_CLASS_HASH,
                                global::TEST_CLASS_HASH,
                                player::TEST_CLASS_HASH,
                                pool::TEST_CLASS_HASH,
                                piece::TEST_CLASS_HASH,
                                piece_type::TEST_CLASS_HASH,
                                team::TEST_CLASS_HASH,
                                tile::TEST_CLASS_HASH];

        // deploy world with models
        let mut world = spawn_test_world(["ok"].span(), models.span());

        // deploy systems contract
        let arena_address = world
            .deploy_contract('salt', arena::TEST_CLASS_HASH.try_into().unwrap());
        let matchmaking_address = world
            .deploy_contract('m', matchmaking::TEST_CLASS_HASH.try_into().unwrap());
        let gov_address = world
            .deploy_contract('gov', gov::TEST_CLASS_HASH.try_into().unwrap());
        let gacha_address = world
            .deploy_contract('gacha', gacha::TEST_CLASS_HASH.try_into().unwrap());
        let teambuilder_address = world
            .deploy_contract('team', teambuilder::TEST_CLASS_HASH.try_into().unwrap());

        let arena_system = IArenaDispatcher { contract_address: arena_address };
        let matchmaking_system = IMatchmakingDispatcher { contract_address: matchmaking_address };
        let gov_system = IGovDispatcher { contract_address: gov_address };
        let gacha_system = IGachaDispatcher {contract_address: gacha_address};
        let teambuilder_system = ITeambuilderDispatcher {contract_address: teambuilder_address};

        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), arena_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), matchmaking_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), gov_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), gacha_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"ok"), teambuilder_address);

        (world, arena_system, matchmaking_system, gov_system, gacha_system, teambuilder_system)
    }

    fn deploy_pieces(ref world: IWorldDispatcher, gov: IGovDispatcher) {
        let a_address = world
            .deploy_contract('a', a::TEST_CLASS_HASH.try_into().unwrap());
        let b_address = world
            .deploy_contract('b', b::TEST_CLASS_HASH.try_into().unwrap());

        gov.add_piece(a_address);
        gov.add_piece(b_address);
    }

    fn setup_game(ref world: IWorldDispatcher, 
                    matchmaking: IMatchmakingDispatcher, 
                    gacha: IGachaDispatcher, 
                    teambuilder: ITeambuilderDispatcher) -> (u32, ContractAddress, ContractAddress) {
        
        let p1 = starknet::contract_address_const::<0x1>();
        set_caller_address(p1);

        let piece_1_id = gacha.mint();
        let team_1_id = teambuilder.create_team();
        teambuilder.add_piece_to_team(team_1_id, piece_1_id);
        
        let game_id = matchmaking.create_game(team_1_id);

        let p2 = starknet::contract_address_const::<0x2>();
        set_caller_address(p2);

        let piece_2_id = gacha.mint();
        let team_2_id = teambuilder.create_team();
        teambuilder.add_piece_to_team(team_2_id, piece_2_id);
        
        matchmaking.join_game(game_id, team_2_id);

        set_caller_address(p1);

        matchmaking.start_game(game_id);

        (game_id, p1, p2)
    }

    #[test]
    fn test_add_type() {
        // caller

        let (mut world, _arena, _matchmaking, gov, _gacha, _teambuilder) = setup();

        deploy_pieces(ref world, gov);

        let pool = get!(world, POOL_ID, (Pool));

        assert!(pool.piece_type_ids.len() == 2, "piece types not added");

    }

    #[test]
    fn test_mint() {
        // caller
        let caller = starknet::contract_address_const::<0x0>();

        let (mut world, _arena, _matchmaking, gov, gacha, _teambuilder) = setup();

        deploy_pieces(ref world, gov);


        let piece_id = gacha.mint();

        let piece = get!(world, piece_id, (Piece));

        assert!(piece.owner == caller, "piece not minted");

    }

    #[test]
    fn test_add_to_team() {

        let (mut world, _arena, _matchmaking, gov, gacha, teambuilder) = setup();

        deploy_pieces(ref world, gov);

        let piece_id = gacha.mint();

        let team_id = teambuilder.create_team();

        teambuilder.add_piece_to_team(team_id, piece_id);

        let team = get!(world, team_id, (Team));

        let piece = get!(world, piece_id, (Piece));

        assert!(team.pieces.len() == 1, "piece not in team");
        assert!(piece.location == Location::Team(team_id), "piece location not updated");



    }
    
    #[test]
    fn test_remove_from_team() {

        let (mut world, _arena, _matchmaking, gov, gacha, teambuilder) = setup();

        deploy_pieces(ref world, gov);

        let piece_id = gacha.mint();

        let team_id = teambuilder.create_team();

        teambuilder.add_piece_to_team(team_id, piece_id);

        let team = get!(world, team_id, (Team));

        let piece = get!(world, piece_id, (Piece));

        assert!(team.pieces.len() == 1, "piece not in team");
        assert!(piece.location == Location::Team(team_id), "piece location not updated");

        teambuilder.remove_piece_from_team(team_id, piece_id);
        let team = get!(world, team_id, (Team));

        let piece = get!(world, piece_id, (Piece));

        assert!(team.pieces.len() == 0, "piece not removed from team");
        assert!(piece.location == Location::Owner, "piece location not updated");

    }

    #[test]
    fn test_create_game() {

        let caller = starknet::contract_address_const::<0x0>();
        let (mut world, _arena, matchmaking, gov, gacha, teambuilder) = setup();

        deploy_pieces(ref world, gov);

        let piece_id = gacha.mint();

        let team_id = teambuilder.create_team();

        teambuilder.add_piece_to_team(team_id, piece_id);
        
        let game_id = matchmaking.create_game(team_id);
        let team = get!(world, team_id, (Team));
        let game = get!(world, game_id, (Game));
        let piece = get!(world, piece_id, (Piece));

        assert!(team.location == Location::Game(game_id), "team location not updated");
        assert!(*game.players.at(0) == caller, "player not added to game");
        assert!(*game.teams.at(0) == team_id, "team not added to game");

    }

    #[test]
    fn test_join_game() {

        let (mut world, _arena, matchmaking, gov, gacha, teambuilder) = setup();

        deploy_pieces(ref world, gov);

        let piece_1_id = gacha.mint();
        let team_1_id = teambuilder.create_team();
        teambuilder.add_piece_to_team(team_1_id, piece_1_id);
        
        let game_id = matchmaking.create_game(team_1_id);

        let p2 = starknet::contract_address_const::<0x1>();
        set_caller_address(p2);

        let piece_2_id = gacha.mint();
        let team_2_id = teambuilder.create_team();
        teambuilder.add_piece_to_team(team_2_id, piece_2_id);
        
        matchmaking.join_game(game_id, team_2_id);

        let team = get!(world, team_2_id, (Team));
        let game = get!(world, game_id, (Game));
        let piece = get!(world, piece_2_id, (Piece));

        assert!(team.location == Location::Game(game_id), "team location not updated");
        assert!(game.players.len() == 2, "player not added to game");
        assert!(*game.teams.at(1) == team_2_id, "team not added to game");
        
    }

    #[test]
    fn test_start_game() {

        let p1 = starknet::contract_address_const::<0x1>();
        let (mut world, _arena, matchmaking, gov, gacha, teambuilder) = setup();

        deploy_pieces(ref world, gov);

        let piece_1_id = gacha.mint();
        let team_1_id = teambuilder.create_team();
        teambuilder.add_piece_to_team(team_1_id, piece_1_id);
        
        let game_id = matchmaking.create_game(team_1_id);

        let p2 = starknet::contract_address_const::<0x2>();
        set_caller_address(p2);

        let piece_2_id = gacha.mint();
        let team_2_id = teambuilder.create_team();
        teambuilder.add_piece_to_team(team_2_id, piece_2_id);
        
        matchmaking.join_game(game_id, team_2_id);
        set_caller_address(p1);

        matchmaking.start_game(game_id);

        let game = get!(world, game_id, (Game));

        assert!(game.status == Status::Active, "game status not updated");

        let (piece_1, pos_1) = get!(world, piece_1_id, (Piece, Position));
        let (piece_2, pos_2) = get!(world, piece_2_id, (Piece, Position));

        assert!(piece_1.location == Location::Game(game_id), "piece location not updated");
        assert!(piece_2.location == Location::Game(game_id), "piece location not updated");

        assert!(pos_1.position.x == 1, "piece 1 position not updated");
        assert!(pos_2.position.y == 5, "piece 2 position not updated");
        
    }

    #[test]
    fn test_move() {
        let (mut world, arena, matchmaking, gov, gacha, teambuilder) = setup();

        deploy_pieces(ref world, gov);

        let (game_id, p1, p2) = setup_game(ref world, matchmaking, gacha, teambuilder);

        set_caller_address(p1);

        let game = get!(world, game_id, (Game));
        let team_id = *game.teams.at(0);
        let team = get!(world, team_id, (Team));
        let piece_id = *team.pieces.at(0);

        let piece_type_id = get!(world, piece_id, (Piece)).piece_type;
        let piece_type_address = get!(world, piece_type_id, (PieceType)).contract;

        let piece_type_dispatcher = IPieceDispatcher {contract_address: piece_type_address};
        let move_0 = *piece_type_dispatcher.get_move_pattern().at(0);
        let position = get!(world, piece_id, (Position));
        let new_x: i8 = position.position.x + move_0.x;
        let to = Vec2 { x: position.position.x + move_0.x, y: position.position.y + move_0.y};

        arena.move(game_id, piece_id, to);

    }

}
