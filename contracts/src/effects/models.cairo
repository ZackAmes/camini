use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Effect {
    #[key]
    effect_id: u32,
    contract: ContractAddress
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct DamageAmt {
    #[key]
    creator: ContractAddress,
    amt: u32
}