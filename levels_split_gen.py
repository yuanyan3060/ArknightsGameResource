import json
from typing import Union, List, Dict
from pathlib import Path
def read_json(path:Union[str, Path])->Union[Dict, List]:
    with open(Path(__file__).parent/path, "r", encoding="UTF-8") as fp:
        return json.loads(fp.read())

maps = read_json("map.json")
levels :List[Dict[str, str]] = []
stage_table = read_json("gamedata/excel/stage_table.json")
roguelike_topic_table = read_json("gamedata/excel/roguelike_topic_table.json")
sandbox_perm_table = read_json("gamedata/excel/sandbox_perm_table.json")
handbook_info_table = read_json("gamedata/excel/handbook_info_table.json")
    
for stageId, data in stage_table["stages"].items():
    if data["levelId"] is None:
        continue
    level = {
        "name":data["name"],
        "code":data["code"],
        "stageId":data["stageId"],
        "levelId":data["levelId"].lower()
    }
    levels.append(level)
for rogue, rogue_data in roguelike_topic_table["details"].items():
    for stageId, data in rogue_data["stages"].items():
        level = {
            "name":data["name"],
            "code":data["code"],
            "stageId":data["id"],
            "levelId":data["levelId"].lower()
        }
        levels.append(level)
for stageId, data in sandbox_perm_table["detail"]["SANDBOX_V2"]["sandbox_1"]["stageData"].items():
    if data["levelId"] is None:
        continue
    level = {
        "name":data["name"],
        "code":data["code"],
        "stageId":data["stageId"],
        "levelId":data["levelId"].lower()
    }
    levels.append(level)
for char_code, data in handbook_info_table["handbookStageData"].items():
    level = {
        "name":data["name"],
        "code":data["code"],
        "stageId":data["stageId"],
        "levelId":data["levelId"].lower()
    }
    levels.append(level)
for i in Path("gamedata/levels/obt/rune").glob("*.json"):
    levelId = i.as_posix().removeprefix("gamedata/levels/").removesuffix(".json")
    level = {
        "name":i.stem,
        "code":i.stem,
        "stageId":i.stem,
        "levelId":levelId
    }
    levels.append(level)
for i in Path("gamedata/levels/activities").glob("*rune/*.json"):
    levelId = i.as_posix().removeprefix("gamedata/levels/").removesuffix(".json")
    level = {
        "name":i.stem,
        "code":i.stem,
        "stageId":i.stem,
        "levelId":levelId
    }
    levels.append(level)
for i in Path("gamedata/levels/obt/crisis/v2").glob("*.json"):
    levelId = i.as_posix().removeprefix("gamedata/levels/").removesuffix(".json")
    level = {
        "name":i.stem,
        "code":i.stem,
        "stageId":i.stem,
        "levelId":levelId
    }
    levels.append(level)

if not Path("generated_level_data").exists():
    Path("generated_level_data").mkdir()

for level in levels:
    name = level["name"]
    code = level["code"]
    stageId = level["stageId"]
    levelId = level["levelId"]
    level_path = levelId.replace("main/level_easy_sub", "main/level_sub")
    level_path = level_path.replace("main/level_easy", "main/level_main")
    level_path = level_path.replace("\\", "/")
    #level_path = level_path.replace("main/level_tough", "main/level_main")
    path = Path("gamedata/levels", f"{level_path}.json")
    try:
        level_data = read_json(path)
        mapData = level_data["mapData"]
        if "width" in mapData and "height" in mapData:
            width = mapData["width"]
            height = mapData["height"]
        else:
            width = len(mapData["map"][0])
            height = len(mapData["map"])

        tiles = []
        routes = level_data["routes"]
        StartTiles = set()
        EndTiles = set()
        for route in routes:
            if route is not None:
                startPosition = (route["startPosition"]["row"], route["startPosition"]["col"])
                StartTiles.add((height-startPosition[0]-1, startPosition[1]))
                endPosition = (route["endPosition"]["row"], route["endPosition"]["col"])
                EndTiles.add((height-endPosition[0]-1, endPosition[1]))
        for row_index, row in enumerate(mapData["map"]):
            tmp = []
            for i, index in enumerate(row):
                tile_data = mapData["tiles"][index]
                isStart = isEnd = False
                if (row_index, i) in StartTiles:
                    isStart = True
                if (row_index, i) in EndTiles:
                    isEnd = True
                tmp.append(
                    {
                        "buildableType": tile_data["buildableType"],
                        "heightType": tile_data["heightType"],
                        "isEnd":not (isEnd and isStart) and isEnd,
                        "isStart": not (isEnd and isStart) and isStart,
                        "tileKey":tile_data["tileKey"]
                    }
                )
            tiles.append(tmp)
        if level_path in maps:
            view = maps[level_path]
        elif (level_path:=level_path.replace("main/level_tough", "main/level_main")) in maps:
            view = maps[level_path]
        else:
            continue
        result = {
            "code": code,
            "height": height,
            "levelId": levelId,
            "name":name,
            "stageId":stageId,
            "tiles": tiles,
            "view": view,
            "width": width
        }
        with open("generated_level_data/" + stageId + "-" + levelId.replace("/", "-") + ".json", "w+", encoding="UTF-8") as fp:
            json.dump(result, fp, indent=4, ensure_ascii=False)
    except Exception as e:
        print(e)
        pass
