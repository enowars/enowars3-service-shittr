# SHITTR SERVICE

KNOWN ISSUES / WON'T FIX
- CSRF is possible, but not of much use?
- No follow restriction limit in GET.sh (g_follow_shittr), because followCnt does not exist (should be follow_cnt) => red herring - nothing is done with that restriction anyway

# CONFIRMED VULNS

## 2nd line of file read - Exploit: n (but works)
- In db.sh, get_user the raw cookie value is passed to cat + sed, which will return the 2nd line from a file as the user name
- I cannot think of an exploit :-/ 
- FIX: Dunno? Properly chroot/escape the file name

## Auth bypass 1 - Exploit: y
- In dh.sh, the service generates seemingly strong (dd if=/dev/urandom) session IDs, but those are only 3-4 characters long, thus brute-forceable.
- An attacker could BF a valid session within the deletion timeout of 15 min, because /logout does not delete the sessions. With valid sessions, the attacker could look for flags.
- FIX: Use longer session ids

## Visibility Bypass 1 - Exploit: n (but works!)
- Viewing a 'private' user's profile and shits is possible at /@<userid>
- The attacker cannot see private user's shits on /diarrhea or /shittrs
- The attacker can, however, see those accounts mentioned in shits OR through an account B that the hidden user is following (B's following shittr list)
- FIX: Prohibit access to hidden user's profiles
- CHECKER
---> Register
---> Set private
---> Post shit with flag
---> Post public shit with "@<myusername>" just took a dump.

## Visibility Bypass 2 - Exploit: no (but works!)
- Viewing a hidden user's shits is possible at /tag/<tag>
- The attacker could guess the hashtags #flag or #enowars and monitor those for shits from the gamebot with a flag
- FIX: Filter hidden user's shits from the hashtag
- CHECKER
---> Register
---> Set private
---> Post shit with flag
---> Post public shit with "#enowars" hashtag

## Visibility Bypass 3 - Exploit: no (but works!)
- If one unfollows himself, then the matching ids-Array in db.sh (fluid_diarrhea) is (), which matches all entries and therefore all shits are displayed.

## Info leak 1 / Crypto 2 - Exploit: no (but works!)
- Directory listing is enabled for /static/, or folders in general
- People can leak the ssl private key and/or the encryption key
- FIX: Disable Directory Listing and/or block access to the files

## Info leak 2 - Exploit: no (but works!)
- HEAD requests can be used to check if folders or files exist
- FIX: Do not allow path traversal

## Info leak 3 - Exploit: no (but works!)
- The HEAD.sh contains a regex that matches against $DEBUG and will happily give away the last 500 lines of debug log. (even if DEBUG=0, bc an URL with a '0' or '1' will match)
- The attacker can obtain flags
- Debug log contains the session id (rand number)
- FIX: Remove the debug log retrieval in HEAD.sh

## Info leak 4'- Exploit: no (but works!)
- If the user is an admin, GET /log will display the last 100 entries for the requesting IP address
- FIX: None (only allow admins to become admins!)

## ADMIN BYPASS 1 - Exploit: no (but works!)
- Register a user name that matches /admin/ 
- The is_admin middleware checks $DEBUG for it's string length (-n), so it will always be true for DEBUG=0 and DEBUG=1 
- The attacker can therefore gain "ADMIN=1" easily
- With that, the attacker can view /diarrhea and /shittrs or hidden user's without restrictions
- FIX: Remove "-n" in the is_admin middleware

## ADMIN BYPASS 2 - Exploit: y (but works!)
- Use the "image-in-tweet" functionality to write a user file to ./users/<md5>.user with Admin=1
- This can be achieved by an attacker by abusing the create_shit() function in db.sh. The regex will match arbitrary paths that contain ".png", e.g. /.png/foo.user would work. The cut -d'/' check can be bypassed, because the final file path is urldecoded again (thus using ..%2f) works.
- FIX: Remove the urldecode on the file path and/or fix the regex to only allow .png files
- TODO: Maybe 

## Crypto 1 - Exploit: yes (but works!)
- The server.sh includes /bin/ in the PATH, so that the our "shit/openssl" tool is called instead of openssl in utils.sh
- Uses simple ECB with the first 16 bytes as the key from enc.key to encrypt shits.
- Shits can be downloaded from /settings, so one can obtain plaintext + ciphertext pairs to recover the key.
- The key can then be used to decrypt other people's private shits!
- FIX: Use more than 16 bytes and/or other crypto algorithm

## RCE 2 - Exploit ??? (only when unpatched file write)
- The shitssl binary has 2 BOFs, of which one is exploitable by creating a file e.g. in the shitposts directory, which will be read and tried to decrypt by the binary.
- If the base64 decoded strings is > 2048 bytes, then it will copy more than it's allowed into a buffer and result in an easy BOF
- FIX: Patch binary and/or limit lengths

## RCE 1 (?) - Exploit ??? (only when unpatched file write)
- The p_downloadshit function creates a tar archive with unquoted expansion * 
- This might (?!) result in a vulnerability like RCE
- FIX: Make tar secure

# Ideas
- I'll probably add some subtle RCE
- Maybe some SQL or Template injection or so (?)
- Maybe some debug options that leak flags?

- Bild-Fetcher nochmal debuggen, ob nicht file://etc/passwd#test.png oder so geht. Redirect von HTTP ist in libcurl deaktiviert
- Implement language choosing based on the Accept-Header
- Implement answering to shits
- (?) Statuscode ist Stunden seit EPOCH Module $realStatuscode