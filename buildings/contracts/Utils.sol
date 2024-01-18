// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Game} from "cog/IGame.sol";
import {State} from "cog/IState.sol";
import {Schema} from "@ds/schema/Schema.sol";

using Schema for State;

function getState(Game ds) returns (State) {
    return ds.getState();
}

function unitHasItem(State state, bytes24 actor, bytes24 item) view returns (bool) {
    for (uint8 bagIndex = 0; bagIndex < 2; bagIndex++) {
        bytes24 bag = state.getEquipSlot(actor, bagIndex);
        if (bag != 0) {
            for (uint8 slot = 0; slot < 4; slot++) {
                (bytes24 resource, /*uint64 balance*/ ) = state.getItemSlot(bag, slot);
                if (resource == item) {
                    return true;
                }
            }
        }
    }
    return false;
}

function getItemSlot(State state, bytes24 actor, bytes24 item) view returns (bytes24, uint8, uint64) {
    for (uint8 bagIndex = 0; bagIndex < 2; bagIndex++) {
        bytes24 bag = state.getEquipSlot(actor, bagIndex);
        if (bag != 0) {
            for (uint8 slot = 0; slot < 4; slot++) {
                (bytes24 resource, uint64 balance) = state.getItemSlot(bag, slot);
                if (resource == item) {
                    return (bag, slot, balance);
                }
            }
        }
    }
    return (0, 0, 0);
}