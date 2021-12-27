local rtn, str
local phone_number
local talking = false
local inviting = false
local ringing = false
local s, e, c
local base_url = "http://172.16.30.40:8000"
local content_type_text = "Content-Type: application/json"

while (true) do

    -- SMARTalk�֘A�̃��O�𒊏o
    cmd = "smart"
    rtn, str = rt.syslogwatch(cmd)
    
    -- ���O������������
    if rtn > 0 then

        -- Lua�p�^�[���Ɉ�v���镶���񂪂���� c �ɑ���Bs �� e �͎̂Ă�
        s, e, c = string.find(str[rtn], "Call to %[sip:(%d-)@smart")

        -- ���M��ԂȂ�
        if c ~= nil then
            -- �ϐ��ɓd�b�ԍ�����
            phone_number = c
            -- �ϐ��𔭐M��Ԃɂ���
            ringing = true
            -- �f�o�b�O�p
            rt.syslog("info", "[NumberDisplay] ���M���O�����o : " .. phone_number)
        -- ���M��Ԃ��H
        else
            -- Lua�p�^�[���Ɉ�v���镶���񂪂���� c �ɑ���Bs �� e �͎̂Ă�
            s, e, c = string.find(str[rtn], "Call from %[sip:(%d-)@smart")
            -- ���M��ԂȂ�
            if c ~= nil then
                -- �ϐ��ɓd�b�ԍ�����
                phone_number = c
                -- �ϐ��𒅐M��Ԃɂ���
                inviting = true
                -- �f�o�b�O�p
                rt.syslog("info", "[NumberDisplay] ���M���O�����o : " .. phone_number)
            end
        end

        -- ���M�E���M����ђʘb���I��
        if (string.find(str[rtn], "disconnected") ~= nil) and (ringing or inviting) then

            -- ���M��ԂȂ�
            if ringing then
                -- �ϐ���񔭐M��Ԃɂ���
                ringing = false
            -- ���M��ԂȂ�
            elseif inviting then
                -- �ϐ�����Ԃɂ���
                inviting = false
            end

            -- �f�o�b�O�p
            rt.syslog("info", "[NumberDisplay] �ؒf����܂���")

            -- API�g�p �f�B�X�v���COFF
            rt.httprequest({
                url = base_url .. "/sip/disconnected",
                method = "GET"
            })

        -- �ʘb��ԂɂȂ����ꍇ
        elseif (string.find(str[rtn], "connected") ~= nil) or ringing then

            -- �f�o�b�O�p
            rt.syslog("info", "[NumberDisplay] �ʘb��ԂƂȂ�܂���")

            -- API�g�p �ʘb��Ԃ�\��
            rt.httprequest({
                url = base_url .. "/sip/connected",
                method = "POST",
                content_type = content_type_text,
                post_text = "{\"status\": " .. (ringing and "\"ringing\"," or "\"inviting\",") .. "\"phone_number\": \"" .. phone_number .. "\"}"
            })
        else
            -- ���M���̏ꍇ(�����@)
            if inviting then

                -- API�g�p
                rt.httprequest({
                    url = base_url .. "/sip/start",
                    method = "POST",
                    content_type = content_type_text,
                    post_text = "{\"status\": " .. (ringing and "\"ringing\"," or "\"inviting\",") .. "\"phone_number\": \"" .. phone_number .. "\"}"
                })
            end
        end
    end
end