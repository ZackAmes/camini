#[dojo::interface]
trait ITeambuilder {
    fn create_team(ref world: IWorldDispatcher) -> u32;
    fn add_piece_to_team(ref world: IWorldDispatcher, team_id: u32, piece_id: u32);
    fn remove_piece_from_team(ref world: IWorldDispatcher, team_id: u32, piece_id: u32);
}


#[dojo::contract]
mod teambuilder {

    use super::ITeambuilder;

    use camini::models::{piece::Piece, team::Team, player::Player};
    use starknet::{ContractAddress, get_caller_address};
    use camini::types::Location;

    #[abi(embed_v0)]
    impl teambuilderImpl of ITeambuilder<ContractState> {

        fn create_team(ref world: IWorldDispatcher) -> u32 {
            let team_id = world.uuid();
            let owner = get_caller_address();
            let pieces = ArrayTrait::new();
            let team = Team { team_id, owner, pieces, location: Location::Owner};

            set!(world, (team));

            team_id
        }

        fn add_piece_to_team(ref world: IWorldDispatcher, team_id: u32, piece_id: u32) {
            let mut team = get!(world, team_id, (Team));
            assert!(team.location == Location::Owner, "team in game");
            assert!((@team.pieces).len() <= 5, "team full");

            let mut piece = get!(world, piece_id, (Piece));
            assert!(piece.location == Location::Owner, "piece not available");
            
            team.pieces.append(piece_id);
            piece.location = Location::Team(team_id);

            assert!(piece.location == Location::Team(team_id), "location not updated");
            set!(world, (team, piece));

        }

        fn remove_piece_from_team(ref world: IWorldDispatcher, team_id: u32, piece_id: u32) {
            let mut team = get!(world, team_id, (Team));
            let mut piece = get!(world, piece_id, (Piece));

            assert!(piece.location == Location::Team(team_id), "piece not in team");

            let mut new_pieces = ArrayTrait::new();
            let mut index = 0;

            while index < team.pieces.len() {
                let to_check = *team.pieces.at(index);

                if to_check != piece_id {
                    new_pieces.append(to_check)
                }

                index+=1;
            };

            piece.location = Location::Owner;
            team.pieces = new_pieces;

            set!(world, (team, piece));

        }
    }
}