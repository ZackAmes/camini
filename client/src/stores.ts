import { writable, derived } from "svelte/store";
import { type SetupResult } from "./dojo/setup";

export const dojoStore = writable<SetupResult>();
export const burnerManagerStore = derived(dojoStore, $store => $store.burnerManager);
