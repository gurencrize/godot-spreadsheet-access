@tool
extends EditorPlugin

const spreadsheet_id = "sample_spreadsheet_id"
const range = "A1:A1000"
const output_file_path = "res://addons/spreadsheet_to_csv/output.txt"
const menu_title = "スプレッドシートからデータをインポート"

func _enter_tree():
    add_tool_menu_item(menu_title, _on_menu_item_pressed)

func _exit_tree():
    remove_tool_menu_item(menu_title)

func _on_menu_item_pressed():
    var http = HTTPRequest.new()
    add_child(http)
    GET_SPREADSHEET_REQUEST.get_sheets_value(http, spreadsheet_id, range, output_file_path)
