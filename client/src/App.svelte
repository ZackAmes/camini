<script lang="ts">
    import type { Entity } from "@dojoengine/recs";
    import { componentValueStore } from "./componentValueStore";
    import { dojoStore, burnerManagerStore } from "./stores";
    import type { ComponentStore } from "./componentValueStore";

    let entityId: Entity;
    let address: string;
    let player: ComponentStore;
    

    $: ({ clientComponents, torii, burnerManager, client } = $dojoStore);

    $: if (torii) entityId = torii.poseidonHash([burnerManager.getActiveAccount()?.address!])

    $: if (dojoStore) player = componentValueStore(clientComponents.Player, entityId);

    $: if (burnerManagerStore) (burnerManager = $burnerManagerStore)

    $: account = burnerManager.account ? burnerManager.account : burnerManager.masterAccount;

    function handleBurnerChange(event: Event) {
        const target = event.target as HTMLSelectElement;
        address = target.value;
        console.log(address)
        burnerManager.select(address);
        console.log(burnerManager.getActiveAccount()?.address)
    }

</script>

<main>
    {#if $dojoStore}
        <p>Setup completed</p>
    {:else}
        <p>Setting up...</p>
    {/if}

    <button on:click={() => burnerManager?.create()}>
        {burnerManager?.isDeploying ? "deploying burner" : "create burner"}
    </button>

    <div class="card">
        <div>{`burners deployed: ${burnerManager.list().length}`}</div>
        <div>
            select signer:{" "}
            <select on:change={handleBurnerChange}>
                {#each burnerManager?.list() as account}
                        <option value={account.address}>
                            {account.address}
                        </option>
                {/each}
            </select>
        </div>
        <div>
            <button on:click={() => burnerManager.clear()}>
                Clear burners
            </button>
            <p>
                You will need to Authorise the contracts before you can
                use a burner. See readme.
            </p>
        </div>
    </div>

    <div class="card">
        <button on:click={() => client.gacha.mint({account})}>Spawn</button>
        
        <div>
            player has {$player?.pieces.length} pieces
        </div>


    </div>

</main>
