class_name convert_json_to_csv

static func convert_and_save(json_data: Dictionary, file_path: String) -> Error:
    if not json_data.has("values"):
        return ERR_INVALID_DATA

    var values: Array = json_data["values"]

    var csv_lines: Array[String] = []
    for row: Array in values:
        var cells: Array[String] = []
        for cell in row:
            var s := str(cell)
            # RFC 4180: カンマ・ダブルクォート・改行を含む場合はクォートで囲む
            if s.contains(",") or s.contains('"') or s.contains("\n") or s.contains("\r"):
                s = '"' + s.replace('"', '""') + '"'
            cells.append(s)
        csv_lines.append(",".join(cells))

    var file := FileAccess.open(file_path, FileAccess.WRITE_READ)
    if file == null:
        return FileAccess.get_open_error()

    file.store_string("\n".join(csv_lines))
    file.close()
    EditorInterface.get_resource_filesystem().scan()
    return OK
