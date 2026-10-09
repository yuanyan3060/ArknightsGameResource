local luaUtils = CS.Torappu.Lua.Util;
































local RewardOnlyMainViewPoolItemView = Class("RewardOnlyMainViewPoolItemView", UIWidget);



function RewardOnlyMainViewPoolItemView:Render(index, model)
  if model == nil or #model.poolModelList < index then
    return;
  end
  self:_InitIfNot();
  self.m_model = model;
  self.m_itemModel = model.poolModelList[index+1];

  local hasSelect = not string.isNullOrEmpty(model.selectPoolId);
  local beSelected = model.selectPoolId == self.m_itemModel.poolId;
  local charId = model.receivedCharId;
  local isReceived = not string.isNullOrEmpty(charId);

  SetGameObjectActive(self._normalPart, not isReceived or not beSelected);
  SetGameObjectActive(self._normalDisplayGroup, not isReceived);
  SetGameObjectActive(self._portraitPart, isReceived and beSelected);
  SetGameObjectActive(self._bgFrame, not isReceived);
  SetGameObjectActive(self._selectFrame, beSelected and not isReceived)

  local color = "";
  if not hasSelect or beSelected then 
    color = self._selectMaskColor;
  elseif not isReceived then
    color = self._unselectMaskColor;
  else 
    color = self._receivedMaskColor;
  end
  self._mainImgMask.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(color);
  local hubPath = CS.Torappu.ResourceUrls.GetRewardOnlyImageHubPath(model.actId);
  self._mainImg.sprite = self:LoadSpriteFromAutoPackHub(hubPath, self.m_itemModel.poolId);
  self._titleName.text = self.m_itemModel.poolName;

  
  SetGameObjectActive(self._indexImg1, index == 0);
  SetGameObjectActive(self._indexImg2, index == 1);
  SetGameObjectActive(self._indexImg3, index == 2);
  SetGameObjectActive(self._indexImg4, index == 3);

  
  if beSelected and isReceived then
    local skinStruct = luaUtils.GetHighestSelectableUISkin(model.receivedCharId, CS.Torappu.EvolvePhase.PHASE_0);
    local sprite = CS.Torappu.CharacterUtil.LoadCharPortrait(skinStruct:GetPortraitId())
    self._portraitImg:SetSprite(sprite)

    local charQuery = CS.Torappu.CharQuery.SimpleChar(charId);
    local suc, charData = CS.Torappu.CharacterUtil.TryGetCharData(charQuery);
    if suc then
      self._rarityImg.sprite = luaUtils.LoadLeftJustifyRarityIcon(charData.rarity);
      self._professionImg.sprite = luaUtils.GetLargeProfessionPic(charData.profession, true);
      self._charName.text = charData.name;
    end
  end
end


function RewardOnlyMainViewPoolItemView:_InitIfNot()
  if self.m_isInited then
    return;
  end
  self.m_isInited = true;

  self.m_poolSlotIndex = tonumber(self._poolSlotIndex);
  self:AddButtonClickListener(self._checkPoolDetailBtn, self._OnClickCheckPoolDetail);
  self:AddButtonClickListener(self._selectPoolBtn, self._OnClickSelectPool);
end


function RewardOnlyMainViewPoolItemView:_OnClickCheckPoolDetail()
  if self.m_model == nil then 
    return;
  end

  Event.Call(self.onClickCheckPoolDetail, self.m_itemModel.poolId);
end

function RewardOnlyMainViewPoolItemView:_OnClickSelectPool()
  if self.m_model == nil then
    return;
  end
  
  Event.Call(self.onClickSelectPool, self.m_itemModel.poolId);
end

return RewardOnlyMainViewPoolItemView;