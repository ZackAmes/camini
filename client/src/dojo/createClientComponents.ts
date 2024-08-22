import { overridableComponent } from "@dojoengine/recs";
import { ContractComponents } from "./generated/bindings/typescript/models.gen";

export type ClientComponents = ReturnType<typeof createClientComponents>;

export function createClientComponents({
    contractComponents,
}: {
    contractComponents: ContractComponents;
}) {
    return {
        ...contractComponents,
        Position: overridableComponent(contractComponents.Position),
        Game: overridableComponent(contractComponents.Game),
        Player: overridableComponent(contractComponents.Player),
        Tile: overridableComponent(contractComponents.Tile),
        DamageAmt: overridableComponent(contractComponents.DamageAmt),
        Global: overridableComponent(contractComponents.Global),
        Piece: overridableComponent(contractComponents.Piece),
        PieceType: overridableComponent(contractComponents.PieceType),
        Pool: overridableComponent(contractComponents.Pool),
        Team: overridableComponent(contractComponents.Team),
        Effect: overridableComponent(contractComponents.Effect),
    };
}
