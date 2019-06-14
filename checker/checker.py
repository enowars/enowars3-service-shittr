from enochecker import BaseChecker, BrokenServiceException, run, OfflineException
from urllib.parse import urlencode
from io import BytesIO
import string, random, faker, pycurl, os, time, re, hashlib

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
            self.putflag_public_public_post,
            self.putflag_public_private_post,
            self.putflag_user_bio
        ]
        self.getflag_funcs = [
            self.getflag_public_public_post,
            self.getflag_public_private_post,
            self.getflag_user_bio
        ]

        # FUCK MY LIFE. I WANNA DIE
        if ':' in self.address:
            self.address = "[{}]".format(self.address)

        self.REG_URL = "https://{}:{}/register".format(self.address, self.port)
        self.LOGIN_URL = "https://{}:{}/login".format(self.address, self.port)
        self.SHIT_URL = "https://{}:{}/shit".format(self.address, self.port)
        self.LOGOUT_URL = "https://{}:{}/logout".format(self.address, self.port)
        self.SETTINGS_URL = "https://{}:{}/settings".format(self.address, self.port)
        self.MYPROFILE_URL = "https://{}:{}/@USERNAME".format(self.address, self.port)

    def putflag_user_bio(self):
        user, pw = self.get_or_create_account()

        self.login(user, pw)

        self.post_settings(self.flag, True)

        self.logout()

    def putflag_public_public_post(self):
        user, pw = self.get_or_create_account()

        self.login(user, pw)

        self.post_shit(self.flag)

        self.logout()

    def putflag_public_private_post(self):
        user, pw = self.get_or_create_account()

        self.login(user, pw)

        self.post_shit(self.flag, private=True)

        self.logout()


    def logout(self):
        ret = self._get_request(self.SHIT_URL, useCookies=True)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")


    def post_settings(self, bio, public):
        ret = self._post_request(self.SETTINGS_URL, {'public': 'on' if public else '', 'bio': bio}, useCookies=True, follow=True)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")


    def post_shit(self, text, private=False):
        ret = self._post_request(self.SHIT_URL, {'private': 'on' if private else '', 'post': text}, useCookies=True, follow=True)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")


    def login(self, user, pw):
        ret = self._post_request(self.LOGIN_URL, {'username': user, 'password': pw}, useCookies=True)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")

    def get_or_create_account(self, existing=False):
        if existing:
            # Return known credentials
            return self.get_account()
        else:
            # Signup
            return self.create_account()

    def get_account(self):
        try:
            user = self.team_db[self.flag]['user']
            pw = self.team_db[self.flag]['pw']
            self.info("I am {} / {}")
            return user, pw
        except KeyError:
            raise BrokenServiceException("Key error -> Flag not found, service down")

    def create_account(self):
        fkr = faker.Faker()
        fkr.seed_instance(self.flag)
        user = fkr.user_name()
        pw = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(random.randint(6,12)))

        ret = self._post_request(self.REG_URL, {'username': user, 'password': pw}, useCookies=True, follow=True)

        print(ret)
        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")


        self.team_db[self.flag] = {
            'user': user,
            'pw' : pw
        }
        self.info("Registered user: {} / {}".format(user, pw))

        return user, pw

    def _get_request(self, url, params=None, useCookies=False, follow=True, *args):
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
            cookie_file = hashlib.md5((self.flag).encode()).hexdigest() + ".cookie"
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

    def _post_request(self, url, params, useCookies=False, follow=True, *args):
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
            cookie_file = hashlib.md5((self.flag).encode()).hexdigest() + ".cookie"
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

    def getflag_public_private_post(self):
        self._get_request(self.LOGIN_URL, useCookies=True)
        user, pw = self.get_or_create_account(existing=True)

        ret = self._get_request(self.MYPROFILE_URL.replace("USERNAME", user), useCookies=True)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")


        if not '''<div class='content'>{}</div>'''.format(self.flag) in str(ret):
            raise BrokenServiceException("Flag not found in /@{}".format(user))

    def getflag_public_public_post(self):
        self._get_request(self.LOGIN_URL, useCookies=True)
        user, pw = self.get_or_create_account(existing=True)

        ret = self._get_request(self.MYPROFILE_URL.replace("USERNAME", user), useCookies=True)

        if not '''1337 WORKS FOR ME''' in ret:
            raise BrokenServiceException("Wrong HTTP status code")

        if not '''Content Type: 1337/5P34K''' in ret:
            raise BrokenServiceException("Wrong Content Type header")

        if not '''<div class='content'>{}</div>'''.format(self.flag) in ret:
            raise BrokenServiceException("Flag {} not found in /@{}: {}".format(self.flag, user, ret))


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


app = ShittrChecker.service
if __name__ == "__main__":
    run(ShittrChecker)
