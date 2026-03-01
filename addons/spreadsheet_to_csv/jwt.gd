class_name JWT
const secret_file_path = "res://addons/spreadsheet_to_csv/secret.json"

static func get_jwt():
    var secret = FileAccess.open(secret_file_path,FileAccess.READ)
    var secret_json = JSON.parse_string(secret.get_as_text())
    var jwt = await JWT.create_jwt(secret_json["client_email"], secret_json["private_key"])    
    return jwt

static func create_jwt(service_email: String, private_key_pem: String) -> String:
    print("JWT新規作成")
    var header = {
        "alg": "RS256",
        "typ": "JWT"
    }

    var now = Time.get_unix_time_from_system()

    var claim = {
        "iss": service_email,
        "scope": "https://www.googleapis.com/auth/spreadsheets.readonly",
        "aud": "https://oauth2.googleapis.com/token",
        "iat": now,
        "exp": now + 3600
    }

    var header_json = JSON.stringify(header)
    var claim_json = JSON.stringify(claim)

    var header_b64 = base64url(header_json.to_utf8_buffer())
    var claim_b64 = base64url(claim_json.to_utf8_buffer())

    var signing_input = header_b64 + "." + claim_b64

    # 秘密鍵読み込み
    var key = CryptoKey.new()
    key.load_from_string(private_key_pem)
    
    var crypto = Crypto.new()
    var signing_buffer = signing_input.sha256_buffer()
    var signature = crypto.sign(
        HashingContext.HashType.HASH_SHA256,
        signing_buffer,
        key
    )
    var signature_b64 = base64url(signature)
    return signing_input + "." + signature_b64

static func base64url(data: PackedByteArray) -> String:
    var b64 = Marshalls.raw_to_base64(data)
    b64 = b64.replace("+", "-")
    b64 = b64.replace("/", "_")
    b64 = b64.replace("=", "")
    return b64
