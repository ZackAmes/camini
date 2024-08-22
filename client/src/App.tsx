import "./App.css";
import { useComponentValue, useQuerySync } from "@dojoengine/react";
import { Entity } from "@dojoengine/recs";
import { useEffect, useState } from "react";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useDojo } from "./dojo/useDojo";

function App() {
    const {
        setup: {
            systemCalls: { move },
            clientComponents: { Position, Global, Pool },
            toriiClient,
            contractComponents,
        },
        account,
    } = useDojo();

    useQuerySync(toriiClient, contractComponents as any, []);

    let global_key = getEntityIdFromKeys([BigInt(0)]) as Entity;
    let pool_key = getEntityIdFromKeys([BigInt(40)]) as Entity;

    let global = useComponentValue(Global, global_key);
    let pool = useComponentValue(Pool, pool_key);


    console.log(global)
    console.log(pool)


    return (
        <>
            <button onClick={() => account?.create()}>
                {account?.isDeploying ? "deploying burner" : "create burner"}
            </button>
            

            <div className="card">
                <div>{`burners deployed: ${account.count}`}</div>
                <div>
                    select signer:{" "}
                    <select
                        value={account ? account.account.address : ""}
                        onChange={(e) => account.select(e.target.value)}
                    >
                        {account?.list().map((account, index) => {
                            return (
                                <option value={account.address} key={index}>
                                    {account.address}
                                </option>
                            );
                        })}
                    </select>
                </div>
                <div>
                    <button onClick={() => account.clear()}>
                        Clear burners
                    </button>
                </div>
            </div>

            <div className="card">
               
            </div>
        </>
    );
}

export default App;
