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
for char_code, data in handbook_info_table["handbookStageData"].items():
    level = {
        "name":data["name"],
        "code":data["code"],
        "stageId":data["stageId"],
        "levelId":data["levelId"].lower()
    }
    levels.append(level)
for i in Path("gamedata\\levels\\obt\\rune").glob("*.json"):
    levelId = i.as_posix().removeprefix("gamedata/levels/").removesuffix(".json")
    level = {
        "name":i.stem,
        "code":i.stem,
        "stageId":i.stem,
        "levelId":levelId
    }
    levels.append(level)
for i in Path("gamedata\\levels\\activities").glob("*rune/*.json"):
    levelId = i.as_posix().removeprefix("gamedata/levels/").removesuffix(".json")
    level = {
        "name":i.stem,
        "code":i.stem,
        "stageId":i.stem,
        "levelId":levelId
    }
    levels.append(level)

result = []
for level in levels:
    name = level["name"]
    code = level["code"]
    stageId = level["stageId"]
    levelId = level["levelId"]
    level_path = levelId.replace("main/level_easy_sub", "main/level_sub")
    level_path = level_path.replace("main/level_easy", "main/level_main")
    #level_path = level_path.replace("main/level_tough", "main/level_main")
    path = Path("gamedata/levels", f"{level_path}.json")
    try:
        level_data = read_json(path)
        width = level_data["mapData"]["width"]
        height = level_data["mapData"]["height"]
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
        for row_index, row in enumerate(level_data["mapData"]["map"]):
            tmp = []
            for i, index in enumerate(row):
                tile_data = level_data["mapData"]["tiles"][index]
                isStart = isEnd = False
                if (row_index, i) in StartTiles:
                    isStart = True
                if (row_index, i) in EndTiles:
                    isEnd = True
                tmp.append(
                    {
                        "heightType": tile_data["heightType"],
                        "buildableType": tile_data["buildableType"],
                        "tileKey":tile_data["tileKey"],
                        "isStart": isStart,
                        "isEnd":isEnd
                    }
                )
            tiles.append(tmp)
        if level_path in maps:
            view = maps[level_path]
        elif (level_path:=level_path.replace("main/level_tough", "main/level_main")) in maps:
            view = maps[level_path]
        else:
            continue
        result.append({
            "name":name,
            "code": code,
            "levelId": levelId,
            "stageId":stageId,
            "width": width,
            "height": height,
            "tiles": tiles,
            "view": view
        })
    except:
        pass

with open("levels.json", "w", encoding="UTF-8") as fp:
    json.dump(result, fp, indent=2, ensure_ascii=False)
