# BASHOR SERVICE

VULNS:

- GET.sh, function g_static: File includsion should be possible
- db.sh, generates weak sessions (file names are 4 chars base64)
- XSS is possible (but not useful?)

- I'll probably add some subtle RCE
- Maybe some SQL or Template injection or so (?)
- Maybe some debug options that leak flags?