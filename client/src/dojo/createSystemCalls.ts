import { AccountInterface } from "starknet";
import {
    Entity,
    Has,
    HasValue,
    World,
    defineSystem,
    getComponentValue,
} from "@dojoengine/recs";
import { uuid } from "@latticexyz/utils";
import { ClientComponents } from "./createClientComponents";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import type { IWorld } from "./generated/bindings/typescript/contracts.gen";
import { Vec2 } from "./generated/bindings/typescript/models.gen";

export type SystemCalls = ReturnType<typeof createSystemCalls>;


export function createSystemCalls(
    { client }: { client: IWorld },
    { }: ClientComponents,
    world: World
) {
    const move = async (account: AccountInterface, game_id: number, piece_id: number, to: Vec2) => {
        
        try {
            await client.arena.move({
                account,
                game_id,
                piece_id,
                to
            });

        } catch (e) {
            console.log(e);
        } finally {
        }
    };
    const attack = async (account: AccountInterface, game_id: number, piece_id: number, target: Vec2) => {
        
        try {
            await client.arena.attack({
                account,
                game_id,
                piece_id,
                target
            });

        } catch (e) {
            console.log(e);
        } finally {
        }
    };

    const mint = async (account: AccountInterface) => {
        
        try {
            await client.gacha.mint({
                account
            });

        } catch (e) {
            console.log(e);
        } finally {
        }
    };
    const create_team = async (account: AccountInterface) => {
        
        try {
            await client.teambuilder.create_team({
                account
            });

        } catch (e) {
            console.log(e);
        } finally {
        }
    };
    const add_piece_to_team = async (account: AccountInterface, team_id: number, piece_id: number) => {
        
        try {
            await client.teambuilder.add_piece_to_team({
                account,
                team_id,
                piece_id
            });

        } catch (e) {
            console.log(e);
        } finally {
        }
    };
    const remove_piece_from_team = async (account: AccountInterface, team_id: number, piece_id: number) => {
        
        try {
            await client.teambuilder.remove_piece_from_team({
                account,
                team_id,
                piece_id
            });

        } catch (e) {
            console.log(e);
        } finally {
        }
    };
    const create_game = async (account: AccountInterface, team_id: number) => {
        
        try {
            await client.matchmaking.create_game({
                account,
                team_id
            });

        } catch (e) {
            console.log(e);
        } finally {
        }
    };
    const join_game = async (account: AccountInterface, game_id: number, team_id) => {
        
        try {
            await client.matchmaking.join_game({
                account,
                game_id,
                team_id
            });

        } catch (e) {
            console.log(e);
        } finally {
        }
    };
    const start_game = async (account: AccountInterface, game_id: number) => {
        
        try {
            await client.matchmaking.start_game({
                account,
                game_id
            });

        } catch (e) {
            console.log(e);
        } finally {
        }
    };
    return {
        move,
        attack,
        mint,
        create_game,
        create_team,
        join_game,
        start_game,
        add_piece_to_team,
        remove_piece_from_team,

        
    };
}
