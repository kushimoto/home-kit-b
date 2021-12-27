local rtn, str
local phone_number
local talking = false
local inviting = false
local ringing = false
local s, e, c
local base_url = "http://172.16.30.40:8000"
local content_type_text = "Content-Type: application/json"

while (true) do

    -- SMARTalk関連のログを抽出
    cmd = "smart"
    rtn, str = rt.syslogwatch(cmd)
    
    -- ログが見つかったら
    if rtn > 0 then

        -- Luaパターンに一致する文字列があれば c に代入。s と e は捨てる
        s, e, c = string.find(str[rtn], "Call to %[sip:(%d-)@smart")

        -- 発信状態なら
        if c ~= nil then
            -- 変数に電話番号を代入
            phone_number = c
            -- 変数を発信状態にする
            ringing = true
            -- デバッグ用
            rt.syslog("info", "[NumberDisplay] 発信ログを検出 : " .. phone_number)
        -- 着信状態か？
        else
            -- Luaパターンに一致する文字列があれば c に代入。s と e は捨てる
            s, e, c = string.find(str[rtn], "Call from %[sip:(%d-)@smart")
            -- 着信状態なら
            if c ~= nil then
                -- 変数に電話番号を代入
                phone_number = c
                -- 変数を着信状態にする
                inviting = true
                -- デバッグ用
                rt.syslog("info", "[NumberDisplay] 着信ログを検出 : " .. phone_number)
            end
        end

        -- 発信・着信および通話が終了
        if (string.find(str[rtn], "disconnected") ~= nil) and (ringing or inviting) then

            -- 発信状態なら
            if ringing then
                -- 変数を非発信状態にする
                ringing = false
            -- 着信状態なら
            elseif inviting then
                -- 変数を非状態にする
                inviting = false
            end

            -- デバッグ用
            rt.syslog("info", "[NumberDisplay] 切断されました")

            -- API使用 ディスプレイOFF
            rt.httprequest({
                url = base_url .. "/sip/disconnected",
                method = "GET"
            })

        -- 通話状態になった場合
        elseif (string.find(str[rtn], "connected") ~= nil) or ringing then

            -- デバッグ用
            rt.syslog("info", "[NumberDisplay] 通話状態となりました")

            -- API使用 通話状態を表示
            rt.httprequest({
                url = base_url .. "/sip/connected",
                method = "POST",
                content_type = content_type_text,
                post_text = "{\"status\": " .. (ringing and "\"ringing\"," or "\"inviting\",") .. "\"phone_number\": \"" .. phone_number .. "\"}"
            })
        else
            -- 着信中の場合(消去法)
            if inviting then

                -- API使用
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