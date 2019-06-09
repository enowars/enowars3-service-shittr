from enochecker import BaseChecker, BrokenServiceException, run
from urllib.parse import urlencode
from io import BytesIO
import string, random, faker, pycurl, os

class ShittrChecker(BaseChecker):
    port = 31337


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
        self.flagfunc = [
            self.putflag_public_public_post,
            self.putflag_prublic_private_post,
            self.putflag_user_bio
        ]

        self.REG_URL = "https://[{}]:{}/register".format(self.address, self.port)
        self.LOGIN_URL = "https://[{}]:{}/login".format(self.address, self.port)
        self.SHIT_URL = "https://[{}]:{}/shit".format(self.address, self.port)
        self.LOGOUT_URL = "https://[{}]:{}/logout".format(self.address, self.port)
        self.SETTINGS_URL = "https://[{}]:{}/settings".format(self.address, self.port)

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

    def putflag_prublic_private_post(self):
        user, pw = self.get_or_create_account()

        self.login(user, pw)

        self.post_shit(self.flag, private=True)

        self.logout()


    def logout(self):
        try:
            ret = self._get_request(self.SHIT_URL, useCookies=True)
            print("Request return is ", ret)
        except:
            raise BrokenServiceException("Cannot login")

    def post_settings(self, bio, public):
        try:
            ret = self._post_request(self.SETTINGS_URL, {'public': 'on' if public else '', 'bio': bio}, useCookies=True)
            print("Request return is ", ret)
        except:
            raise BrokenServiceException("Cannot post public shit")

    def post_shit(self, text, private=False):
        try:
            ret = self._post_request(self.SHIT_URL, {'private': 'on' if private else '', 'post': text}, useCookies=True)
            print("Request return is ", ret)
        except:
            raise BrokenServiceException("Cannot post public shit")

    def login(self, user, pw):
        try:
            ret = self._post_request(self.LOGIN_URL, {'username': user, 'password': pw}, useCookies=True)
            print("Request return is ", ret)
        except:
            raise BrokenServiceException("Cannot login user")

    def get_or_create_account(self):
        if False:
            # Return known credentials
            return self.get_account()
        else:
            # Signup
            return self.create_account()

    def get_account(self):
        pass

    def create_account(self):
        fkr = faker.Faker()
        user = fkr.user_name()
        pw = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(random.randint(6,12)))

        try:
            ret = self._post_request(self.REG_URL, {'username': user, 'password': pw}, useCookies=True)
        except:
            raise BrokenServiceException("Cannot register new user")


        self.info("Registered user: {} / {}".format(user, pw))

        return user, pw

    def _get_request(self, url, params=None, useCookies=False, *args): 
        buffer = BytesIO()
        c = pycurl.Curl()
        c.setopt(c.VERBOSE, True)
        c.setopt(c.URL, url)
        c.setopt(pycurl.SSL_VERIFYPEER, 0)   
        c.setopt(pycurl.SSL_VERIFYHOST, 0)

        if useCookies:
            cookie_file = self.flag + 'cookie'
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

        c.perform()
        c.close()

        if useCookies:
            with open(cookie_file, 'r') as cookie_f:
                self.team_db[cookie_file] = cookie_f.read()

        return buffer.getvalue().decode('utf-8')

    def _post_request(self, url, params, useCookies=False, *args): 
        buffer = BytesIO()
        c = pycurl.Curl()
        c.setopt(c.VERBOSE, True)
        c.setopt(c.URL, url)
        c.setopt(pycurl.SSL_VERIFYPEER, 0)   
        c.setopt(pycurl.SSL_VERIFYHOST, 0)
        c.setopt(c.POSTFIELDS, urlencode(params))

        if useCookies:
            cookie_file = self.flag + 'cookie'
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

        c.perform()
        c.close()

        if useCookies:
            with open(cookie_file, 'r') as cookie_f:
                self.team_db[cookie_file] = cookie_f.read()

        return buffer.getvalue().decode('utf-8')

    def putflag(self):
        self.flagfunc[self.flag_idx]()

    def getflag(self):
        pass

    def putnoise(self):
        pass

    def getnoise(self):
        pass

    def havoc(self):
        pass

    def exploit(self):
        pass


app = ShittrChecker.service
if __name__ == "__main__":
    run(ShittrChecker)
