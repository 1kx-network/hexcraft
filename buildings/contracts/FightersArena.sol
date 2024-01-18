// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Game} from "cog/IGame.sol";
import {State} from "cog/IState.sol";
import {Schema} from "@ds/schema/Schema.sol";
import {Actions} from "@ds/actions/Actions.sol";
import {BuildingKind} from "@ds/ext/BuildingKind.sol";

import "Register.sol";

using Schema for State;

contract FightersArena is BuildingKind {
    function use(Game ds, bytes24 buildingInstance, bytes24 actor, bytes memory /*payload*/ ) public {

        State state = GetState(ds);

        require(!(UnitIsCarryingItem(state, actor, FRIENDLY_PUPPY_COMPANION_ITEM_ID)), "You are already carrying a Friendly Puppy Companion");
        require(!(UnitIsCarryingItem(state, actor, GLOCK_WITH_MAGIC_ITEM_ID)), "You are already carrying a Glock 19 with magic");
        require(!(UnitIsCarryingItem(state, actor, GREATSWORD_OF_DAWN_ITEM_ID)), "You already own the greatsword of dawn");
        require(!(UnitIsCarryingItem(state, actor, STRONG_HOLY_KITESHIELD_ITEM_ID)), "You are already carrying a strong holy Kiteshield");
        require(!(UnitIsCarryingItem(state, actor, TAYLOR_SWITFT_GUITAR_ITEM_ID)), "You are already carrying Taylor Swift's Guitar");

        ds.getDispatcher().dispatch(abi.encodeCall(Actions.CRAFT, (buildingInstance)));
    }

    function construct(Game ds, bytes24 buildingInstance, bytes24, /*actor*/ bytes memory /*payload*/ ) public {
    }

    function GetState(Game ds) internal returns (State) {
        return ds.getState();
    }

    function UnitIsCarryingItem(State state, bytes24 actor, bytes24 item) internal view returns (bool) {
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
}
