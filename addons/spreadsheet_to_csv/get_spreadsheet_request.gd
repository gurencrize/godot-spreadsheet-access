class_name GET_SPREADSHEET_REQUEST
static func get_sheets_value(http:HTTPRequest, sheet_id:String, range:String, output_path:String):
    var url = "https://sheets.googleapis.com/v4/spreadsheets/%s/values/%s" % [
        sheet_id,
        range.uri_encode()
    ]
    var access_token = await GET_GOOGLE_ACCESS_TOKEN.get_access_token(http)

    http.request(
        url,
        PackedStringArray(["Authorization: Bearer " + access_token]),
        HTTPClient.METHOD_GET
    )
    
    var result = await http.request_completed
    if result[1] != 200:
        print("[get_sheets_value]異常なHTTPステータス:",result[1])
        return
    var text = result[3].get_string_from_utf8()
    var json = JSON.parse_string(text)
    var error = convert_json_to_csv.convert_and_save(json, output_path)
    if error == OK:
        print("ファイル保存完了")
