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

function bytes32ToString(bytes32 x) pure returns (string memory) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        bytes1 char = bytes1(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (uint j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
}