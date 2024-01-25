// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Game} from "cog/IGame.sol";
import {Dispatcher} from "cog/IDispatcher.sol";
import {State, CompoundKeyDecoder} from "cog/IState.sol";
import {Schema, Node, DEFAULT_ZONE, Q, R, S, Kind} from "@ds/schema/Schema.sol";
import {Actions} from "@ds/actions/Actions.sol";
import {BuildingKind} from "@ds/ext/BuildingKind.sol";
import "@ds/utils/LibString.sol";

using Schema for State;

contract Headquarter is BuildingKind {
    bytes24[] private redTeam;
    bytes24[] private blueTeam;

    mapping(bytes24 => bool) private crafted;

    // function declerations only used to create signatures for the use payload
    // these functions do not have their own definitions
    function join() external {}

    function start(bytes24 redBaseID, bytes24 blueBaseID) external {}

    function reset() external {}

    function use(
        Game ds,
        bytes24 buildingInstance,
        bytes24 actor,
        bytes calldata payload
    ) override public {
        State state = GetState(ds);

        // decode payload and call one of _join, _start, _claim or _reset
        if ((bytes4)(payload) == this.join.selector) {
            _join(ds, state, actor, buildingInstance);
        } else if ((bytes4)(payload) == this.start.selector) {
            (bytes24 redBaseID, bytes24 blueBaseId) = abi.decode(
                payload[4:],
                (bytes24, bytes24)
            );
            _start(ds, state, buildingInstance, redBaseID, blueBaseId);
        } else if ((bytes4)(payload) == this.reset.selector) {
            _reset(ds, buildingInstance);
        }
    }

    /*
     * Functions to handle game logic
     */

    function _join(
        Game ds,
        State state,
        bytes24 unitId,
        bytes24 buildingId
    ) private {
        // check game not in progress
        bool gameActive = uint256(state.getData(buildingId, "gameActive")) == 1;

        // bool gameActive = state.getDataBool(buildingId, "gameActive");
        // bool gameActive = state.getDataUint256(buildingId, "gameActive") == 1;
        // bool gameActive = uint256(state.getData(buildingId, "gameActive")) == 1;
        if (gameActive) {
            revert("Can't join while a game is already active");
        }

        for (uint256 i = 0; i < redTeam.length; i++) {
            if (redTeam[i] == unitId) revert("Already joined");
        }
        for (uint256 i = 0; i < blueTeam.length; i++) {
            if (blueTeam[i] == unitId) revert("Already joined");
        }

        // Assign a team
        if (redTeam.length <= blueTeam.length) {
            redTeam.push(unitId);
            assignUnitToTeam(ds, "red", unitId, buildingId);
        } else {
            blueTeam.push(unitId);
            assignUnitToTeam(ds, "blue", unitId, buildingId);
        }
    }

    function assignUnitToTeam(
        Game ds,
        string memory team,
        bytes24 unitId,
        bytes24 buildingId
    ) private {
        Dispatcher dispatcher = ds.getDispatcher();

        if (
            keccak256(abi.encodePacked(team)) ==
            keccak256(abi.encodePacked("red"))
        ) {
            processTeam(dispatcher, buildingId, "redTeam", redTeam, unitId);
        } else if (
            keccak256(abi.encodePacked(team)) ==
            keccak256(abi.encodePacked("blue"))
        ) {
            processTeam(dispatcher, buildingId, "blueTeam", blueTeam, unitId);
        } else {
            revert("invalid team");
        }
    }

    function processTeam(
        Dispatcher dispatcher,
        bytes24 buildingId,
        string memory teamPrefix,
        bytes24[] storage teamUnits,
        bytes24 unitId
    ) private {
        dispatcher.dispatch(
            abi.encodeCall(
                Actions.SET_DATA_ON_BUILDING,
                (
                    buildingId,
                    string(abi.encodePacked(teamPrefix, "Length")),
                    bytes32(uint256(teamUnits.length))
                )
            )
        );

        string memory teamUnitIndex = string(
            abi.encodePacked(
                teamPrefix,
                "Unit_",
                LibString.toString(uint256(teamUnits.length) - 1)
            )
        );

        dispatcher.dispatch(
            abi.encodeCall(
                Actions.SET_DATA_ON_BUILDING,
                (buildingId, teamUnitIndex, bytes32(unitId))
            )
        );
    }

    function _start(
        Game ds,
        State state,
        bytes24 buildingId,
        bytes24 redBaseID,
        bytes24 blueBaseID
    ) private {
        Dispatcher dispatcher = ds.getDispatcher();

        // check teams have at least one each
        uint256 redTeamLength = uint256(
            state.getData(buildingId, "redTeamLength")
        );
        uint256 blueTeamLength = uint256(
            state.getData(buildingId, "blueTeamLength")
        );
        if (redTeamLength == 0 || blueTeamLength == 0) {
            revert("Can't start, both teams must have at least 1 player");
        }

        require(redBaseID != blueBaseID, "Bases must be different");

        // set team buildings
        dispatcher.dispatch(
            abi.encodeCall(
                Actions.SET_DATA_ON_BUILDING,
                (buildingId, "buildingIdRed", bytes32(redBaseID))
            )
        );
        dispatcher.dispatch(
            abi.encodeCall(
                Actions.SET_DATA_ON_BUILDING,
                (buildingId, "buildingIdBlue", bytes32(blueBaseID))
            )
        );

        // TODO check is blueBaseId is a valid building
        // TODO check is redBaseId is a valid building

        // gameActive
        dispatcher.dispatch(
            abi.encodeCall(
                Actions.SET_DATA_ON_BUILDING,
                (buildingId, "gameActive", bytes32(uint256(1)))
            )
        );
    }

    function _reset(Game ds, bytes24 buildingId) private {
        Dispatcher dispatcher = ds.getDispatcher();

        // todo - do we check if all claims have been made ?
        // for now allwing reset any time which requires some trust :)

        dispatcher.dispatch(
            abi.encodeCall(
                Actions.SET_DATA_ON_BUILDING,
                (buildingId, "gameActive", bytes32(uint256(0)))
            )
        );
        delete redTeam;
        delete blueTeam;
        dispatcher.dispatch(
            abi.encodeCall(
                Actions.SET_DATA_ON_BUILDING,
                (buildingId, "blueTeamLength", bytes32(0))
            )
        );
        dispatcher.dispatch(
            abi.encodeCall(
                Actions.SET_DATA_ON_BUILDING,
                (buildingId, "redTeamLength", bytes32(0))
            )
        );
        dispatcher.dispatch(
            abi.encodeCall(
                Actions.SET_DATA_ON_BUILDING,
                (buildingId, "buildingIdRed", bytes32(0))
            )
        );
        dispatcher.dispatch(
            abi.encodeCall(
                Actions.SET_DATA_ON_BUILDING,
                (buildingId, "buildingIdBlue", bytes32(0))
            )
        );

        // delete playerClassSelected;
        // dispatcher.dispatch(
        //     abi.encodeCall(
        //         Actions.SET_DATA_ON_BUILDING,
        //         (buildingId, "buildingKindIdBlue", bytes32(0))
        //     )
        // );
    }

    /*
     * Functions to handle character classes
     */
     function setCrafted(bytes24 actor) public {
        crafted[actor] = true;
    }

    function hasCrafted(bytes24 actor) public returns (bool) {
        return crafted[actor];
    }
    
    /*
     * Helper functions
     */

    function GetState(Game ds) internal returns (State) {
        return ds.getState();
    }
}
