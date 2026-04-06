
local CheckinVideoDynImageView = Class("CheckinVideoDynImageView", UIWidget);


function CheckinVideoDynImageView:Render(iconId, hubPath)
  if not string.isNullOrEmpty(iconId) and self._imgIcon ~= nil then
    self._imgIcon.sprite = self:LoadSpriteFromAutoPackHub(hubPath, iconId);
  end
end

return CheckinVideoDynImageView;