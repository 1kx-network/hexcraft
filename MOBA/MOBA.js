import ds from "downstream";

const nullBytes24 = `0x${"00".repeat(24)}`;
const redBuildingTopId = "14";
const blueBuildingTopId = "14";

export default async function update(state) {
  //
  // Action handler functions
  //
  console.log('update 0')

  // An action can set a form submit handler which will be called after the action along with the form values
  let handleFormSubmit;

  const join = () => {
    const mobileUnit = getMobileUnit(state);

    const payload = ds.encodeCall("function join()", []);

    ds.dispatch({
      name: "BUILDING_USE",
      args: [selectedBuilding.id, mobileUnit.id, payload],
    });
  };

  // NOTE: Because the 'action' doesn't get passed the form values we are setting a global value to a function that will
  const start = () => {
    handleFormSubmit = startSubmit;
  };

  const startSubmit = (values) => {
    const selectedBuildingKindBaseRed = values["buildingKindIdRed"];
    const selectedBuildTypeBaseBlue = values["buildingKindIdBlue"];

    // Verify selected buildings are different from each other
    if (selectedBuildingKindBaseRed == selectedBuildTypeBaseBlue) {
      console.error("Team buildings must be different from each other", {
        selectedBuildingKindBaseRed,
        selectedBuildTypeBaseBlue,
      });
      return;
    }

    const mobileUnit = getMobileUnit(state);
    const payload = ds.encodeCall(
      "function start(bytes24 redBaseID, bytes24 blueBaseID)",
      [selectedBuildingKindBaseRed, selectedBuildTypeBaseBlue]
    );

    ds.dispatch({
      name: "BUILDING_USE",
      args: [selectedBuilding.id, mobileUnit.id, payload],
    });
  };

  const reset = () => {
    const mobileUnit = getMobileUnit(state);
    const payload = ds.encodeCall("function reset()", []);

    ds.dispatch({
      name: "BUILDING_USE",
      args: [selectedBuilding.id, mobileUnit.id, payload],
    });
  };

  // uncomment this to browse the state object in browser console
  // this will be logged when selecting a unit and then selecting an instance of this building
  // very spammy for a plugin marked as alwaysActive
  // logState(state);

  // \todo
  // plugins run for a buildingKind and if marked as alwaysActive in the manifest
  // this update will ba called every regardless of whether a building is selected
  // so we need to find all HQs on the map and update them each in turn
  //
  // for now we just update the first we find
  const dvbBuildingName = "MOBA";
  const selectedBuilding = state.world?.buildings.find(
    (b) => b.kind?.name?.value == dvbBuildingName
  );


  // early out if we don't have any buildings or state isn't ready
  if (!selectedBuilding || !state?.world?.buildings) {
    console.log("NO MOBA BUILDING FOUND 8");
    return {
      version: 1,
      map: [],
      components: [
        {
          id: "moba",
          type: "building",
          content: [
            {
              id: "default",
              type: "inline",
              html: "",
              buttons: [],
            },
          ],
        },
      ],
    };
  }


  const {
    gameActive,
    buildingKindIdRed,
    buildingKindIdBlue,
    redTeamLength,
    blueTeamLength,
  } = getHQData(selectedBuilding);
  console.log({
    gameActive,
    buildingKindIdRed,
    buildingKindIdBlue,
    redTeamLength,
    blueTeamLength,
  })
  const localBuildings = range5(state, selectedBuilding);
  const redCount = countBuildings(localBuildings, buildingKindIdRed);
  const blueCount = countBuildings(localBuildings, buildingKindIdBlue);
  console.log({ localBuildings, redCount, blueCount })
  // check current game state:
  // - NotStarted : GameActive == false
  // - Running : GameActive == true && endBlock < currentBlock
  // - GameOver : GameActive == true && endBlock >= currentBlock

  // we build a list of button objects that are rendered in the building UI panel when selected
  let buttonList = [];

  // we build an html block which is rendered above the buttons
  let htmlBlock =
    '<h3><span style="color: red">Red</span> vs <span style="color: blue">Blue</span></h3>';

  const canJoin = !gameActive;

  const canStart =
    !gameActive &&
    redTeamLength > 0 &&
    blueTeamLength > 0

  console.log({ canStart, canJoin })
  if (canJoin) {
    htmlBlock += `<p>total players: ${redTeamLength + blueTeamLength}</p></br>`;
  }

  // Show what team the unit is on
  const mobileUnit = getMobileUnit(state);

  let isOnTeam = false;
  if (mobileUnit) {
    let unitTeam = "";

    for (let i = 0; i < redTeamLength; i++) {
      if (mobileUnit.id == getHQTeamUnit(selectedBuilding, "red", i)) {
        unitTeam = "🔴";
        break;
      }
    }

    if (unitTeam === "") {
      for (let i = 0; i < blueTeamLength; i++) {
        if (
          mobileUnit.id == getHQTeamUnit(selectedBuilding, "blue", i)
        ) {
          unitTeam = "🔵";
          break;
        }
      }
    }

    if (unitTeam !== "") {
      isOnTeam = true;
      htmlBlock += `
                <p>You are on team ${unitTeam}</p></br>
            `;
    }
  }

  console.log({ isOnTeam })

  if (!gameActive) {

    if (!isOnTeam) {

      buttonList.push({
        text: `Join Game`,
        type: "action",
        action: join,
        disabled: !canJoin || isOnTeam,
      });
    } else {
      // Check reason why game can't start
      const waitingForStartCondition =
        redTeamLength != blueTeamLength ||
        redTeamLength + blueTeamLength < 2;
      let startConditionMessage = "";
      if (waitingForStartCondition) {
        if (redTeamLength + blueTeamLength < 2) {
          startConditionMessage = "Waiting for players...";
        } else if (redTeamLength != blueTeamLength) {
          startConditionMessage = "Teams must be balanced...";
        }
      }

      buttonList.push({
        text: waitingForStartCondition
          ? startConditionMessage
          : "Start",
        type: "action",
        action: start,
        disabled: !canStart || redTeamLength != blueTeamLength,
      });
    }
  }

  // Show options to select team buildings
  htmlBlock += `
            <h3>Select Team Buildings</h3>
            <p>🔴 Team 🔴</p>
            ${getBuildingKindSelectHtml(
    state,
    redBuildingTopId,
    "buildingKindIdRed"
  )}
            <p>🔵 Team 🔵</p>
            ${getBuildingKindSelectHtml(
    state,
    blueBuildingTopId,
    "buildingKindIdBlue"
  )}
        `;

  if (gameActive) {
    // Display selected team buildings
    const buildingKindRed =
      state.world.buildingKinds.find((b) => b.id === buildingKindIdRed) ||
      {};
    const buildingKindBlue =
      state.world.buildingKinds.find(
        (b) => b.id === buildingKindIdBlue
      ) || {};
    htmlBlock += `
            <h3>Team Buildings:</h3>
            <p>Team 🔴: ${buildingKindRed.name?.value}</p>
            <p>Team 🔵: ${buildingKindBlue.name?.value}</p></br>

        `;

    if (redCount !== blueCount) {
      const redWon = redCount > blueCount;
      htmlBlock += `
            <p>Team <b>${redWon ? "RED" : "BLUE"}</b> have won the match!</p>
            <p style="text-align: center;">${redWon ? "🔴🏆🔴" : "🔵🏆🔵"}</p>
            `;
    }


  }
  // Reset is always offered (requires some trust!)
  buttonList.push({
    text: "Reset",
    type: "action",
    action: reset,
    disabled: false,
  });

  console.log({ htmlBlock })
  return {
    version: 1,
    map: [],
    components: [
      {
        id: "moba",
        type: "building",
        content: [
          {
            id: "default",
            type: "inline",
            html: htmlBlock,
            submit: (values) => {
              if (typeof handleFormSubmit == "function") {
                handleFormSubmit(values);
              }
            },
            buttons: buttonList,
          },
        ],
      },
    ],
  };
}

function getHQData(selectedBuilding) {
  const gameActive = getDataBool(selectedBuilding, "gameActive");
  // const startBlock = getDataInt(selectedBuilding, "startBlock");
  //  const endBlock = getDataInt(selectedBuilding, "endBlock");
  const buildingKindIdRed = getDataBytes24(
    selectedBuilding,
    "buildingKindIdRed"
  );
  const buildingKindIdBlue = getDataBytes24(
    selectedBuilding,
    "buildingKindIdBlue"
  );
  const redTeamLength = getDataInt(selectedBuilding, "redTeamLength");
  const blueTeamLength = getDataInt(selectedBuilding, "blueTeamLength");

  return {
    gameActive,
    buildingKindIdRed,
    buildingKindIdBlue,
    redTeamLength,
    blueTeamLength,
  };
}

function getHQTeamUnit(selectedBuilding, team, index) {
  return getDataBytes24(selectedBuilding, `${team}TeamUnit_${index}`);
}

// search the buildings list ofr the display buildings we're gpoing to use
// for team counts and coutdown

function getBuildingKindSelectHtml(state, buildingTopId, selectId) {
  return `
        <select id="${selectId}" name="${selectId}">
            ${state.world.buildingKinds
      .filter(
        (b) =>
          b.model &&
          b.model.value.substring(3, 5) === buildingTopId
      )
      .map(
        (b) => `
                .filter((b) => b.model && b.model.value.substring(3, 5) === buildingTopId)
                    <option value="${b.id}">${b.name.value}</option>
                `
      )}
        </select>
    `;
}

// --- Generic State helper functions

function getMobileUnit(state) {
  return state?.selected?.mobileUnit;
}

// search through all the bags in the world to find those belonging to this eqipee
// eqipee maybe a building, a mobileUnit or a tile
function getEquipeeBags(state, equipee) {
  return equipee
    ? (state?.world?.bags || []).filter(
      (bag) => bag.equipee?.node.id === equipee.id
    )
    : [];
}

function logState(state) {
  console.log("State sent to pluging:", state);
}

// get an array of buildings withiin 5 tiles of building
function range5(state, building) {
  const range = 5;
  const tileCoords = getTileCoords(building?.location?.tile?.coords);
  let i = 0;
  const foundBuildings = [];
  for (let q = tileCoords[0] - range; q <= tileCoords[0] + range; q++) {
    for (
      let r = tileCoords[1] - range;
      r <= tileCoords[1] + range;
      r++
    ) {
      let s = -q - r;
      let nextTile = [q, r, s];
      if (distance(tileCoords, nextTile) <= range) {
        state?.world?.buildings.forEach((b) => {
          if (!b?.location?.tile?.coords) return;

          const buildingCoords = getTileCoords(
            b.location.tile.coords
          );
          if (
            buildingCoords[0] == nextTile[0] &&
            buildingCoords[1] == nextTile[1] &&
            buildingCoords[2] == nextTile[2]
          ) {
            foundBuildings[i] = b;
            i++;
          }
        });
      }
    }
  }
  return foundBuildings;
}

function hexToSignedDecimal(hex) {
  if (hex.startsWith("0x")) {
    hex = hex.substr(2);
  }

  let num = parseInt(hex, 16);
  let bits = hex.length * 4;
  let maxVal = Math.pow(2, bits);

  // Check if the highest bit is set (negative number)
  if (num >= maxVal / 2) {
    num -= maxVal;
  }

  return num;
}

function getTileCoords(coords) {
  return [
    hexToSignedDecimal(coords[1]),
    hexToSignedDecimal(coords[2]),
    hexToSignedDecimal(coords[3]),
  ];
}

function distance(tileCoords, nextTile) {
  return Math.max(
    Math.abs(tileCoords[0] - nextTile[0]),
    Math.abs(tileCoords[1] - nextTile[1]),
    Math.abs(tileCoords[2] - nextTile[2])
  );
}

// -- Building Data

function getData(buildingInstance, key) {
  return getKVPs(buildingInstance)[key];
}

function getDataBool(buildingInstance, key) {
  var hexVal = getData(buildingInstance, key);
  return typeof hexVal === "string" ? parseInt(hexVal, 16) == 1 : false;
}

function getDataInt(buildingInstance, key) {
  var hexVal = getData(buildingInstance, key);
  return typeof hexVal === "string" ? parseInt(hexVal, 16) : 0;
}

function getDataBytes24(buildingInstance, key) {
  var hexVal = getData(buildingInstance, key);
  return typeof hexVal === "string" ? hexVal.slice(0, -16) : nullBytes24;
}

function getKVPs(buildingInstance) {
  return buildingInstance.allData.reduce((kvps, data) => {
    kvps[data.name] = data.value;
    return kvps;
  }, {});
}

const countBuildings = (buildingsArray, kindID) => {
  return buildingsArray.filter((b) => b.kind?.id == kindID).length;
};


// the source for this code is on github where you can find other example buildings:
// https://github.com/playmint/ds/tree/main/contracts/src/example-plugins
