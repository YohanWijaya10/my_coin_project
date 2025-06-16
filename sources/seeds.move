module seeds::seeds {
    use sui::coin::{TreasuryCap, Coin, create_currency, mint as coin_mint, burn as coin_burn, value};
    use sui::transfer::{public_transfer, public_freeze_object};
    use sui::tx_context::sender;
    use sui::object::new;

    //
    // === Error Code Constants ===
    //
    const E_NOT_OWNER: u64 = 1;
    const E_MAX_SUPPLY_EXCEEDED: u64 = 2;

    
    // === Token Type Definition ===
    //
    public struct SEEDS has drop {}

    //
    // === Supply & Ownership Metadata ===
    //
    public struct Supply has key, store {
        id: UID,
        total: u64,
        max: u64,
    }

    public struct OwnerCap has key, store {
        id: UID,
        owner: address,
    }

    //
    // === Init Function (Bukan Entry) ===
    //
    fun init(witness: SEEDS, ctx: &mut TxContext) {
        let (treasury, metadata) = create_currency(
            witness,
            6,
            b"SEEDS",
            b"SEED TOKEN",
            b"Token untuk reward, game, dan utilitas",
            option::none(),
            ctx
        );
    
        public_freeze_object(metadata);
        public_transfer(treasury, sender(ctx));
    
        let supply = Supply {
            id: new(ctx),
            total: 0,
            max: 5_000_000_000,
        };
        public_transfer(supply, sender(ctx));
    
        let owner_cap = OwnerCap {
            id: new(ctx),
            owner: sender(ctx),
        };
        public_transfer(owner_cap, sender(ctx));
    }
    

    //
    // === Mint Coin (Only by Owner) ===
    //
    public entry fun mint_coin(
        treasury_cap: &mut TreasuryCap<SEEDS>,
        supply: &mut Supply,
        owner_cap: &OwnerCap,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        assert!(sender(ctx) == owner_cap.owner, E_NOT_OWNER);
        assert!(supply.total + amount <= supply.max, E_MAX_SUPPLY_EXCEEDED);

        supply.total = supply.total + amount;

        let coin = coin_mint(treasury_cap, amount, ctx);
        public_transfer(coin, recipient);
    }

    //
    // === Burn Coin (Only by Owner) ===
    //
    public entry fun burn_coin(
        treasury_cap: &mut TreasuryCap<SEEDS>,
        supply: &mut Supply,
        coin: Coin<SEEDS>,
        owner_cap: &OwnerCap,
        ctx: &mut TxContext,
    ) {
        assert!(sender(ctx) == owner_cap.owner, E_NOT_OWNER);

        let burn_amount = value(&coin);
        supply.total = supply.total - burn_amount;
        coin_burn<SEEDS>(treasury_cap, coin);
    }

    //
    // === Getters ===
    //
    public fun get_total_supply(supply: &Supply): u64 {
        supply.total
    }

    public fun get_max_supply(supply: &Supply): u64 {
        supply.max
    }

    public fun get_owner(owner_cap: &OwnerCap): address {
        owner_cap.owner
    }
}
