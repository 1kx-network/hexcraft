// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Game} from "cog/IGame.sol";
import {State} from "cog/IState.sol";
import {Schema} from "@ds/schema/Schema.sol";
import {Actions} from "@ds/actions/Actions.sol";
import {BuildingKind} from "@ds/ext/BuildingKind.sol";

import "Register.sol";
import "Utils.sol";

using Schema for State;

contract WizardsMaze is BuildingKind {
    function use(Game ds, bytes24 buildingInstance, bytes24 actor, bytes memory /*payload*/ ) public {

        State state = getState(ds);

        require(!(unitHasItem(state, actor, GREATSWORD_OF_DAWN_ITEM_ID)), "You are already carrying the greatsword of dawn");
        require(!(unitHasItem(state, actor, FRIENDLY_PUPPY_COMPANION_ITEM_ID)), "You are already carrying a Friendly Puppy Companion");
        require(!(unitHasItem(state, actor, GLOCK_WITH_MAGIC_ITEM_ID)), "You already own a Glock 19 with magic");
        require(!(unitHasItem(state, actor, STRONG_HOLY_KITESHIELD_ITEM_ID)), "You are already carrying a strong holy Kiteshield");
        require(!(unitHasItem(state, actor, TAYLOR_SWITFT_GUITAR_ITEM_ID)), "You are already carrying Taylor Swift's Guitar");

        ds.getDispatcher().dispatch(abi.encodeCall(Actions.CRAFT, (buildingInstance)));
    }

    function construct(Game ds, bytes24 buildingInstance, bytes24 /*actor*/, bytes memory /*payload*/ ) public {
    }
}
