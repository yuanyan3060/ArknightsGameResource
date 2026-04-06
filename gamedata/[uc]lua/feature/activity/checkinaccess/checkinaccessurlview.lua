local luaUtils = CS.Torappu.Lua.Util;





local CheckinAccessUrlView = Class("CheckinAccessUrlView", UIPanel);


function CheckinAccessUrlView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end
  self:SetVisible(data.showUrlBtn);
  if not data.showUrlBtn then
    return;
  end
  self._textDesc.text = data.urlBtnDesc;
  self._imgBkg.color = data.btnColor;
  luaUtils.SetActiveIfNecessary(self._panelTrackPoint, data.showTrackPoint);
end

return CheckinAccessUrlView;