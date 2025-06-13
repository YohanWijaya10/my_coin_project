module seeds::coin_transfer {
    use sui::coin::Coin;
    use seeds::seeds::SEEDS;

    public fun transfer_seeds(coin: Coin<SEEDS>, recipient: address) {
        transfer::public_transfer(coin, recipient);
    }
}
