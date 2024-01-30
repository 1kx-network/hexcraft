// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Game} from "cog/IGame.sol";
import {State} from "cog/IState.sol";
import {Schema} from "@ds/schema/Schema.sol";
import {Actions} from "@ds/actions/Actions.sol";
import {BuildingKind} from "@ds/ext/BuildingKind.sol";

using Schema for State;

bytes24 constant HEADQUARTER_BUILDING_KIND_ID = 0xbe92755c0000000000000000818eec0b0000000000000004;

interface Headquarter {
    function isGameActive() external view returns (bool);
}

contract RedBase is BuildingKind {
    function use(Game ds, bytes24 buildingInstance, bytes24, /*actor*/ bytes memory /*payload*/ ) override public {
        ds.getDispatcher().dispatch(abi.encodeCall(Actions.CRAFT, (buildingInstance)));
    }
    function construct(Game ds, bytes24 /*buildingInstance*/, bytes24 actor, bytes memory /*payload*/ ) override public {

        State state = ds.getState();
        Headquarter hq = Headquarter(state.getImplementation(HEADQUARTER_BUILDING_KIND_ID));

        // check already crafted
        require(!hq.isGameActive(), "game already started");
    }
}
