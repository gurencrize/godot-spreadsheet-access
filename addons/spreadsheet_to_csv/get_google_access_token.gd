class_name GET_GOOGLE_ACCESS_TOKEN
const token_file_path = "res://addons/spreadsheet_to_csv/access_token.json"

static func request_access_token(http:HTTPRequest, jwt: String):
    var body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=" + jwt

    http.request(
        "https://oauth2.googleapis.com/token",
        ["Content-Type: application/x-www-form-urlencoded"],
        HTTPClient.METHOD_POST,
        body
    )
    var result = await http.request_completed
    if result[1] != 200:
        print("[request_access_token]異常なHTTPステータス:",result[1])
        return
    var value = result[3].get_string_from_utf8()
    var json = JSON.parse_string(value)
    if json.has("access_token") == false:
        return
    var content:Dictionary = {
        "expire_date": Time.get_ticks_msec() + 1000 * 60 * 59, # 安全マージン1分取るよ！
        "access_token": json["access_token"]
    }
    var file = FileAccess.open(token_file_path,FileAccess.WRITE_READ)
    assert(file != null)
    file.store_string(JSON.stringify(content))
    print("トークン保存完了")
    return json["access_token"]

static func get_access_token(http:HTTPRequest):
    if FileAccess.file_exists(token_file_path) == false:
        # ファイル自体ないので取得する
        return await get_new_token(http)
    var file = FileAccess.open(token_file_path,FileAccess.READ)
    var content = JSON.parse_string(file.get_as_text())
    if content.has("expire_date") == false or content.has("access_token") == false:
        # 無いので取得する
        file.close()
        return await get_new_token(http)
    if content["expire_date"] <= Time.get_ticks_msec():
        # 有効期限が切れているので再取得する
        file.close()
        return await get_new_token(http)
    return content["access_token"]

static func get_new_token(http:HTTPRequest):
    print("新しいアクセストークンを取得")
    var jwt:String = await JWT.get_jwt()
    var token = await request_access_token(http, jwt)
    return token
