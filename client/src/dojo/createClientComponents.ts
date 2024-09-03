import { overridableComponent } from "@dojoengine/recs";
import type { ContractComponents } from "./models.gen";

export type ClientComponents = ReturnType<typeof createClientComponents>;

export function createClientComponents({
  contractComponents,
}: {
  contractComponents: ContractComponents;
}) {
  return {
    ...contractComponents,
    Position: overridableComponent(contractComponents.Position),
    DamageAmt: overridableComponent(contractComponents.DamageAmt),
    Game: overridableComponent(contractComponents.Game),
    Global: overridableComponent(contractComponents.Global),
    Piece: overridableComponent(contractComponents.Piece),
    PieceType: overridableComponent(contractComponents.PieceType),
    Player: overridableComponent(contractComponents.Player),
    Pool: overridableComponent(contractComponents.Pool),
    Team: overridableComponent(contractComponents.Team),
    Tile: overridableComponent(contractComponents.Tile),
  };
}
