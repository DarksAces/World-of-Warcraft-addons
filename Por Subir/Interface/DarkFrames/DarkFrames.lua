local function Darken(texture)
    if texture and texture.SetVertexColor then
        texture:SetVertexColor(0.3, 0.3, 0.3)
    end
end

for i, v in pairs({
    PlayerFrameTexture,
    TargetFrameTextureFrameTexture,
    PetFrameTexture,
    PartyMemberFrame1Texture,
    PartyMemberFrame2Texture,
    PartyMemberFrame3Texture,
    PartyMemberFrame4Texture,
}) do
    Darken(v)
end
