#!/usr/bin/env python3
import argparse, json, os, shutil, sys, datetime, re
from typing import Optional, Tuple

def timestamp() -> str:
    return datetime.datetime.now().strftime("%Y%m%d-%H%M%S")

def make_backup(path: str) -> str:
    base = os.path.basename(path)
    bak = f"{path}.{timestamp()}.bak"
    shutil.copy2(path, bak)
    print(f"[backup] Created backup: {bak}")
    return bak

def try_decode_json_string(s: str, max_rounds: int = 6) -> Tuple[Optional[dict], Optional[str]]:
    """
    Try to turn an over-escaped JSON *string* into a real Python object.
    Strategy:
      1) Try json.loads(s)
      2) If that fails, iteratively 'unescape' and re-try:
         - Use unicode_escape decoding (collapses sequences like \\" -> ", \\/ -> /, \\\\ -> \)
         - As a fallback, apply a few safe textual normalizations
    Returns (parsed_obj, last_error_text)
    """
    last_err = None
    candidate = s

    for i in range(max_rounds):
        try:
            return json.loads(candidate), None
        except Exception as e:
            last_err = str(e)

        # First: decode escape sequences
        try:
            candidate_next = bytes(candidate, "utf-8").decode("unicode_escape")
        except Exception:
            candidate_next = candidate

        # If nothing changed, try small targeted normalizations
        if candidate_next == candidate:
            # common over-escapes in these files
            candidate_next = candidate_next.replace("\\/", "/")
            # extremely conservative de-escape around obvious key/value quote boundaries
            candidate_next = re.sub(r'\\"([A-Za-z0-9_@#{}\-]+)\\"(?=\s*:)', r'"\1"', candidate_next)  # keys
            candidate_next = re.sub(r'(?<=:\s*)\\\"', '"', candidate_next)  # opening quote of a value
            candidate_next = re.sub(r'\\\"(?=\s*[},])', '"', candidate_next)  # closing quote of a value

        candidate = candidate_next

    return None, last_err

def fix_file(path: str) -> int:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    if "DataEntityMetadataJson" not in data or not isinstance(data["DataEntityMetadataJson"], dict):
        print(f"[warn] No DataEntityMetadataJson dict found in {path}. Nothing to fix.")
        return 0

    demj = data["DataEntityMetadataJson"]
    fixed = 0
    failed = []

    for k, v in list(demj.items()):
        if isinstance(v, str):
            parsed, err = try_decode_json_string(v)
            if parsed is not None and isinstance(parsed, (dict, list)):
                demj[k] = parsed
                fixed += 1
                print(f"[fix] Decoded DataEntityMetadataJson['{k}'] from string to object.")
            else:
                failed.append((k, err))
        # else already a dict/list — leave as-is

    # Write back only if something changed
    if fixed > 0:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"[write] Wrote fixed JSON to {path}")

    if failed:
        print("\n[error] Could not decode the following keys:")
        for k, e in failed:
            print(f"  - {k}: {e}")

    return fixed

def main():
    ap = argparse.ArgumentParser(description="Fix double-/over-escaped DataEntityMetadataJson blobs in Canvas TableDefinition JSON.")
    ap.add_argument("file", help="Path to the JSON file (e.g., pkgs/TableDefinitions/AssessmentHistory.json).")
    args = ap.parse_args()

    path = args.file
    if not os.path.isfile(path):
        print(f"[fatal] File not found: {path}")
        sys.exit(1)

    make_backup(path)
    fixed = fix_file(path)

    if fixed == 0:
        print("[info] No double-encoded entries were changed (or none found).")
    else:
        print(f"[done] Fixed {fixed} entr{'y' if fixed==1 else 'ies'} under DataEntityMetadataJson.")

if __name__ == "__main__":
    main()
