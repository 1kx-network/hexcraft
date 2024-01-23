// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Actions} from "@ds/actions/Actions.sol";
import {BuildingKind} from "@ds/ext/BuildingKind.sol";
import {Dispatcher} from "cog/IDispatcher.sol";
import {Game} from "cog/IGame.sol";
import {State} from "cog/IState.sol";
import {Schema} from "@ds/schema/Schema.sol";

import "Register.sol";
import "Utils.sol";

using Schema for State;

contract FightersArena is BuildingKind {
    function use(Game ds, bytes24 buildingInstance, bytes24 actor, bytes memory /*payload*/ ) override public {

        // Dispatcher dispatcher = ds.getDispatcher();
        State state = ds.getState();

        // string playerIdentifier = bytes32ToString(keccak256((abi.encodePacked(actor))));

        // the game needs to be started
        // require(uint256(state.getData(HEADQUARTER_BUILDING_ID, "gameActive")) == 1, "Game has not started");

        // require(uint256(state.getData(HEADQUARTER_BUILDING_ID, string.concat("crafted_", bytes32ToString(actor)))) == 0, "You have already crafted your item");

        // dispatcher.dispatch(
        //     abi.encodeCall(
        //         Actions.SET_DATA_ON_BUILDING,
        //         (
        //                 HEADQUARTER_BUILDING_ID, 
        //                 string.concat("crafted_", bytes32ToString(actor)), 
        //                 bytes32(uint256(1))
        //         )
        //     )
        // );

        require(!(unitHasItem(state, actor, FRIENDLY_PUPPY_COMPANION_ITEM_ID)), "You are already carrying a Friendly Puppy Companion");
        require(!(unitHasItem(state, actor, GLOCK_WITH_MAGIC_ITEM_ID)), "You are already carrying a Glock 19 with magic");
        require(!(unitHasItem(state, actor, GREATSWORD_OF_DAWN_ITEM_ID)), "You already own the greatsword of dawn");
        require(!(unitHasItem(state, actor, STRONG_HOLY_KITESHIELD_ITEM_ID)), "You are already carrying a strong holy Kiteshield");
        require(!(unitHasItem(state, actor, TAYLOR_SWITFT_GUITAR_ITEM_ID)), "You are already carrying Taylor Swift's Guitar");

        ds.getDispatcher().dispatch(abi.encodeCall(Actions.CRAFT, (buildingInstance)));
    }
}
