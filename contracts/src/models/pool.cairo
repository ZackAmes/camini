use camini::pieces::pieces::{IPieceDispatcher, IPiece};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Pool {
    #[key]
    pool_id: u32,
    piece_type_ids: Array<u32>;
}