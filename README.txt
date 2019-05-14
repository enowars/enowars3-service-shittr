# BASHOR SERVICE

VULNS:

- GET.sh, function g_static: File includsion should be possible
- db.sh, function get_user: Path traversal with cookie value (exploitable?)
- db.sh, generates weak sessions (file names are 4 chars base64)
- XSS is possible (but not useful?)
- CSRF is possible (but not useful? => add people as friends, see their posts + flags (?))
- Private Profiles are still accessible over /@PROFILEID
- Directory Listing and keys exposed in /static/

- I'll probably add some subtle RCE
- Maybe some SQL or Template injection or so (?)
- Maybe some debug options that leak flags?

- Statuscode ist Stunden seit EPOCH Module $realStatuscode
- Add error/success messages
- Implement that if two people are following each other, they see their shits
- Implement rendering of images (+SSRF)
- Implement debug/error log
- Implement Auth bypass (e.g. debug)
- Show public accounts/shits on the diarrhea page only if public was chosen => Hide non-public shits