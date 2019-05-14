# BASHOR SERVICE

# VULNS:

- GET.sh, function g_static: File includsion should be possible
- db.sh, function get_user: Path traversal with cookie value (exploitable?)
- db.sh, generates weak sessions (file names are 4 chars base64)
- XSS is possible (but not useful?)
- CSRF is possible (but not useful? => add people as friends, see their posts + flags (?))
- Private Profiles are still accessible over /@PROFILEID
- Directory Listing and keys exposed in /static/
- Shits are encrypted using a 16 byte ECB AES! => Recover the key, get all shits and fine. (Same initial key for all teams :D)
- No follow restriction limit in GET.sh (g_follow_shittr), because followCnt does not exist (should be follow_cnt)

# CONFIRMED VULNS

## Visibility Bypass 1
- Viewing a 'private' user's profile and shits is possible at /@<userid>
- The attacker cannot see private user's shits on /diarrhea or /shittrs
- The attacker can, however, see those accounts mentioned in shits OR through an account B that the hidden user is following (B's following shittr list)
- FIX: Prohibit access to hidden user's profiles
- TODO: Checker implementation

## Visibility Bypass 2
- Viewing a hidden user's shits is possible at /tag/<tag>
- The attacker could guess the hashtags #flag or #enowars and monitor those for shits from the gamebot with a flag
- FIX: Filter hidden user's shits from the hashtag
- TODO: Checker implementation

# Ideas
- I'll probably add some subtle RCE
- Maybe some SQL or Template injection or so (?)
- Maybe some debug options that leak flags?

- Statuscode ist Stunden seit EPOCH Module $realStatuscode
- Implement that if two people are following each other, they see their shits
- Implement rendering of images (+SSRF)
- Implement debug/error log
- Implement Auth bypass (e.g. debug)
- Show public accounts/shits on the diarrhea page only if public was chosen => Hide non-public shits