#[dojo::interface]
trait IEffect {
    fn apply(ref world: IWorldDispatcher, target: u32) -> bool;
}