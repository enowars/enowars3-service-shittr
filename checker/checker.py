from enochecker import BaseChecker, BrokenServiceException, run, OfflineException
from urllib.parse import urlencode
from io import BytesIO
import string, random, faker, pycurl, os, time, re, hashlib, sys

class ShittrChecker(BaseChecker):
    port = 31337

    flag_count = 3
    noise_count = 1
    havoc_count = 1

    # self.flag
    #   - Flagge in putflag
    #   - Garbage in putnoise
    # self.flag_round: Runde in der die Flage bekommen wurde
    # self.flag_idx: Flag index 0..N
    # self.round: Immer die derzeitige Runde
    # self.timeout: In der Zeit fertig werden
    # self.team_id: ID von dem Ziel-Team
    # self.address: Ziel IP ohne port
    #
    # Exceptions:
    # - raise BrokenServiceException("Fuck me")
    # - OfflineException("oO")
    # - Ansonsten return ist OK
    #
    def __init__(self, *args, **kwargs):
        super(ShittrChecker, self).__init__(*args, **kwargs)
        self.putflag_funcs = [
            self.putflag_user_bio,              # idx = 0
            self.putflag_public_private_post,   # idx = 1
            self.putflag_private_public_post,   # idx = 2
            self.putflag_private_private_post,  # idx = 3
        ]
        self.getflag_funcs = [
            self.getflag_user_bio,              # idx = 0
            self.getflag_public_private_post,   # idx = 1
            self.getflag_private_public_post,   # idx = 2
            self.getflag_private_private_post,  # idx = 3
        ]

        # FUCK MY LIFE. I WANNA DIE
        if ':' in self.address:
            self.address = "[{}]".format(self.address)

        self.REG_URL = "https://{}:{}/register".format(self.address, self.port)
        self.LOGIN_URL = "https://{}:{}/login".format(self.address, self.port)
        self.SHIT_URL = "https://{}:{}/shit".format(self.address, self.port)
        self.DIARRHEA_URL = "https://{}:{}/diarrhea".format(self.address, self.port)
        self.LOGOUT_URL = "https://{}:{}/logout".format(self.address, self.port)
        self.SETTINGS_URL = "https://{}:{}/settings".format(self.address, self.port)
        self.MYPROFILE_URL = "https://{}:{}/@USERNAME".format(self.address, self.port)


        self.fkr = faker.Faker()
        self.fkr.seed_instance(self.flag)

        if not self.flag in self.team_db.keys():
            self.team_db[self.flag] = {}
            self.info("Created DB!", self.team_db)

    def putflag(self):
        self.putflag_funcs[self.flag_idx]()

    def getflag(self):
        self.getflag_funcs[self.flag_idx]()

    def putnoise(self):
        pass

    def getnoise(self):
        pass

    def havoc(self):
        if self.round % 3 == 0:
            current_time = time.time()
            for f in os.listdir():
                if not '.cookie' in f:
                    continue
                creation_time = os.path.getctime(f)
                if (current_time - creation_time) // (5 * 60):
                    os.unlink(f)

    def exploit(self):
        pass

    def putflag_user_bio(self):
        user, pw = self.get_or_create_account()

        self.login(user, pw)

        self.post_settings(bio=self.flag)

        self.logout()

    def getflag_user_bio(self):
        self._get_request(self.LOGIN_URL, useCookies=True)
        user, pw = self.get_or_create_account(existing=True)

        self.info("Logging in as {} / {}".format(user, pw))
        self.login(user, pw)

        ret = self._get_request(self.SETTINGS_URL, useCookies=True)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")


        if not '''<textarea name='bio'  class="form-control">{}</textarea>'''.format(self.flag) in str(ret):
            raise BrokenServiceException("Flag not found in /settings")


    def putflag_public_private_post(self):
        user, pw = self.get_or_create_account()

        self.login(user, pw)

        self.post_shit(self.flag, private=True)

        self.logout()

    def getflag_public_private_post(self):
        self._get_request(self.LOGIN_URL, useCookies=True)
        user, pw = self.get_or_create_account(existing=True)

        self.info("Logging in as {} / {}".format(user, pw))
        self.login(user, pw)

        if random.randint(0,512) % 2 == 0:
            ret = self._get_request(self.DIARRHEA_URL, useCookies=True)
        else:
            ret = self._get_request(self.MYPROFILE_URL.replace("USERNAME", user), useCookies=True)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")


        if not '''<div class='content'>{}</div>'''.format(self.flag) in str(ret):
            raise BrokenServiceException("Flag not found in /@{}".format(user))


    def putflag_private_public_post(self):
        user, pw = self.get_or_create_account()
        self.login(user, pw)
        self.post_settings(public=False)
        self.post_shit(self.flag, private=False)
        self.logout()

        user2, pw2 = self.get_or_create_account(idx=1)
        self.login(user2, pw2, idx=1)
        self.post_shit("Uhh, looks like @{} just took a huge dump.".format(user))
        self.logout()

    def getflag_private_public_post(self):
        self._get_request(self.LOGIN_URL, useCookies=True)
        user, pw = self.get_or_create_account(existing=True)

        self.info("Logging in as {} / {}".format(user, pw))
        self.login(user, pw)

        if random.randint(0,512) % 2 == 0:
            ret = self._get_request(self.DIARRHEA_URL, useCookies=True)
        else:
            ret = self._get_request(self.MYPROFILE_URL.replace("USERNAME", user), useCookies=True)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")


        if not '''<div class='content'>{}</div>'''.format(self.flag) in str(ret):
            raise BrokenServiceException("Flag not found in /@{}".format(user))

    def putflag_private_private_post(self):
        user, pw = self.get_or_create_account()
        self.login(user, pw)
        self.post_settings(public=False)
        self.post_shit(self.flag, private=True)

        self.post_shit("In times of war, there is no time to shit. #enowars",private=False)

        self.logout()

    def getflag_private_private_post(self):
        self._get_request(self.LOGIN_URL, useCookies=True)
        user, pw = self.get_or_create_account(existing=True)

        self.info("Logging in as {} / {}".format(user, pw))
        self.login(user, pw)

        if random.randint(0,512) % 2 == 0:
            ret = self._get_request(self.DIARRHEA_URL, useCookies=True)
        else:
            ret = self._get_request(self.MYPROFILE_URL.replace("USERNAME", user), useCookies=True)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")


        if not '''<div class='content'>{}</div>'''.format(self.flag) in str(ret):
            raise BrokenServiceException("Flag not found in /@{}".format(user))


    def post_settings(self, bio="Hello, I'm using shittr!", public=True, idx=0):
        ret = self._post_request(self.SETTINGS_URL, {'public': 'on' if public else '', 'bio': bio}, useCookies=True, follow=True, idx=idx)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")


    def post_shit(self, text, private=False,idx=0):
        ret = self._post_request(self.SHIT_URL, {'private': 'on' if private else '', 'post': text}, useCookies=True, follow=True, idx=idx)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")

    def login(self, user, pw, idx=0):
        ret = self._post_request(self.LOGIN_URL, {'username': user, 'password': pw}, useCookies=True, idx=idx)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")

    def logout(self,idx=0):
        ret = self._get_request(self.SHIT_URL, useCookies=True, idx=idx)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")

    def get_or_create_account(self, existing=False, idx=0):
        if existing:
            # Return known credentials
            user, pw = self.get_account(idx=idx)
        else:
            # Signup
            user, pw = self.create_account(idx=idx)

        print("Login is: ", user, pw)
        return user, pw

    def get_account(self, idx=0):
        try:
            self.info(self.team_db[self.flag])
            user = self.team_db[self.flag]['user'+str(idx)]
            pw = self.team_db[self.flag]['pw'+str(idx)]
            self.info("I am {} / {}")
            return user, pw
        except KeyError:
            raise BrokenServiceException("Key error -> Flag not found, service down")

    def create_account(self, idx=0):
        user = self.fkr.user_name()
        pw = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(random.randint(6,12)))

        ret = self._post_request(self.REG_URL, {'username': user, 'password': pw}, useCookies=True, follow=True)

        if '''n0p3, user already exists''' in ret:
            raise BrokenServiceException("User already exists")

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")

        temp = self.team_db[self.flag]
        temp.update({
            'user'+str(idx): user,
            'pw'+str(idx) : pw
        })
        self.team_db[self.flag] = temp
        self.info("Registered user: {} / {}".format(user, pw))

        return user, pw

    def _get_request(self, url, params=None, useCookies=False, follow=True, idx=0, *args):
        buffer = BytesIO()
        c = pycurl.Curl()
        c.setopt(c.WRITEDATA, buffer)
        c.setopt(c.VERBOSE, True)
        c.setopt(c.FOLLOWLOCATION, follow)
        c.setopt(c.URL, url)
        c.setopt(pycurl.TIMEOUT, 5)
        c.setopt(pycurl.HEADER, True)
        c.setopt(pycurl.USERAGENT, self.http_useragent)
        c.setopt(pycurl.SSL_VERIFYPEER, 0)
        c.setopt(pycurl.SSL_VERIFYHOST, 0)

        if useCookies:
            cookie_file = hashlib.md5((str(self.flag) + str(idx)).encode()).hexdigest() + ".cookie"
            if not os.path.exists(cookie_file):
                (open(cookie_file, 'w')).close()

            try:
                cookie_value = self.team_db[cookie_file]
            except:
                cookie_value = ''

            with open(cookie_file, 'w') as cookie_f:
                cookie_f.write(cookie_value)
                c.setopt(pycurl.COOKIEFILE, cookie_file)
                c.setopt(pycurl.COOKIEJAR, cookie_file)

        try:
            c.perform()
            c.close()
        except pycurl.error:
            raise OfflineException("Service not reachable")

        if useCookies:
            with open(cookie_file, 'r') as cookie_f:
                self.team_db[cookie_file] = cookie_f.read()

        return buffer.getvalue().decode('utf-8')

    def _post_request(self, url, params, useCookies=False, follow=True,idx=0, *args):
        buffer = BytesIO()
        c = pycurl.Curl()
        c.setopt(c.WRITEDATA, buffer)
        c.setopt(c.VERBOSE, True)
        c.setopt(c.FOLLOWLOCATION, follow)
        c.setopt(c.URL, url)
        c.setopt(c.POSTFIELDS, urlencode(params))
        c.setopt(pycurl.TIMEOUT, 5)
        c.setopt(pycurl.HEADER, True)
        c.setopt(pycurl.USERAGENT, self.http_useragent)
        c.setopt(pycurl.SSL_VERIFYPEER, 0)
        c.setopt(pycurl.SSL_VERIFYHOST, 0)

        if useCookies:
            cookie_file = hashlib.md5((str(self.flag) + str(idx)).encode()).hexdigest() + ".cookie"
            if not os.path.exists(cookie_file):
                (open(cookie_file, 'w')).close()

            try:
                cookie_value = self.team_db[cookie_file]
            except:
                cookie_value = ''

            with open(cookie_file, 'w') as cookie_f:
                cookie_f.write(cookie_value)
                c.setopt(pycurl.COOKIEFILE, cookie_file)
                c.setopt(pycurl.COOKIEJAR, cookie_file)

        try:
            c.perform()
            c.close()
        except pycurl.error:
            raise OfflineException("Service unreachable")

        if useCookies:
            with open(cookie_file, 'r') as cookie_f:
                self.team_db[cookie_file] = cookie_f.read()

        return buffer.getvalue().decode('utf-8')


app = ShittrChecker.service
if __name__ == "__main__":
    run(ShittrChecker)
